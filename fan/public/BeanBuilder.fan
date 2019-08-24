
** Static methods for creating Fantom objects. Don't 'make()' your beans, 'build()' them instead! 
@Js mixin BeanBuilder {
	
	** Creates an instance of the given type, using the most appropriate ctor for the given args.
	** Ctors with *it-blocks* are always favoured over ctors without.
	static Obj? build(Type type, [Field:Obj?]? fieldVals := null, Obj?[]? ctorArgs := null) {
		// BeanFactory.doCreate() is a lot more succinct, but creates a LOT more classes! 

		// check the basics
		if ((fieldVals == null || fieldVals.isEmpty) && (ctorArgs == null || ctorArgs.isEmpty)) {
			// we're being asked to "build" an instance, not find a defVal - so let's look for a ctor
			
			ctors := ReflectUtils.findCtors(type, Type#.emptyList)
			if (ctors.size == 1)
				return ctors.first.call

			// if no def-ctor, try an empty it-block
			itBlockFunc	:= Field.makeSetFunc([:])
			ctors = ReflectUtils.findCtors(type, [itBlockFunc.typeof])
			if (ctors.size == 1)
				return ctors.first.call(itBlockFunc)

			// okay, last ditch attempt - look for a defVal to make Lists, etc...
			return defVal(type)
		}

		// with const types - everything must be set via the ctor
		if (type.isConst) {

			// with field types, there must be an it-block at the end
			if (fieldVals != null && !fieldVals.isEmpty) {
				// guard against adding it-blocks to Int[]
				if (ctorArgs == null)	ctorArgs = List.makeObj(1)
				else					ctorArgs = List.makeObj(ctorArgs.size + 1).addAll(ctorArgs)
				itBlockFunc	:= Field.makeSetFunc(fieldVals.toImmutable)	// note the .toImmutable()
				ctorArgs.add(itBlockFunc)
			}
			
			// with no field types, just look for a matching ctor
			argTypes := ctorArgs.map { it?.typeof }
			ctors	 := ReflectUtils.findCtors(type, argTypes)
			if (ctors.size == 0) throw Err(msg_noCtorFound(type, argTypes))
			if (ctors.size  > 1) throw Err(msg_tooManyCtorsFound(type, ctors.map { it.name }, argTypes))
			return ctors.first.callList(ctorArgs)
		}

		// with non-const types - fields *may* be set after construction
		if (fieldVals == null || fieldVals.isEmpty) {
			// no field types - so back to basic ctor matching

			// we have ctor args - so we MUST use them
			argTypes := ctorArgs.map { it?.typeof }
			ctors	 := ReflectUtils.findCtors(type, argTypes)
			if (ctors.size == 0) throw Err(msg_noCtorFound(type, argTypes))
			if (ctors.size  > 1) throw Err(msg_tooManyCtorsFound(type, ctors.map { it.name }, argTypes))
			return ctors.first.callList(ctorArgs)
		}

		// we HAVE field vals - so *try* to tag them into an it-block
		itBlockFunc	:= Field.makeSetFunc(fieldVals)
		
		if (ctorArgs == null || ctorArgs.isEmpty) {
			//	look for basic it-block 
			argTypes := [itBlockFunc.typeof]
			ctors	 := ReflectUtils.findCtors(type, argTypes)
			if (ctors.size == 1)
				return ctors.first.call(itBlockFunc)

			obj := defVal(type)	// it is fine to call defVal here - 'cos we've already looked for an it-block ctor
			fieldVals.each |val, field| { field.set(obj, val) }
			return obj
		}

		// guard against adding it-blocks to Int[]
		ctorArgs = List.makeObj(ctorArgs.size + 1).addAll(ctorArgs)
		
		// we have ctor args - so we MUST use them
		// try first with it-block
		ctorArgs.add(itBlockFunc)
		argTypes := ctorArgs.map { it?.typeof }
		ctors	 := ReflectUtils.findCtors(type, argTypes)
		if (ctors.size == 1)
			return ctors.first.callList(ctorArgs)

		// if not, do it the hard way
		ctorArgs.removeAt(-1)
		argTypes.removeAt(-1)
		ctors	 = ReflectUtils.findCtors(type, argTypes)		
		if (ctors.size == 0) throw Err(msg_noCtorFound(type, argTypes))
		if (ctors.size  > 1) throw Err(msg_tooManyCtorsFound(type, ctors.map { it.name }, argTypes))

		obj := ctors.first.callList(ctorArgs)
		fieldVals.each |val, field| { field.set(obj, val) }
		return obj
	}
	
	private static Str msg_noCtorFound(Type type, Type?[] argTypes) {
		"Could not find a ctor on ${type.qname} to match argument types - ${argTypes}".replace("sys::", "")
	}

	private static Str msg_tooManyCtorsFound(Type type, Str[] ctorNames, Type?[] argTypes) {
		"Found more than 1 ctor on ${type.qname} ${ctorNames} that match argument types - ${argTypes}".replace("sys::", "")
	}
	
	** Returns a default value for the given type. 
	** Use as a replacement for [Type.make()]`sys::Type.make`.
	** 
	** Returned objects are *not* guaranteed to be immutable. 
	** Call 'toImmutable()' on returned object if you need 'const' Lists and Maps.
	** 
	** The default type is determined by the following algorithm:
	** 1. If the type is nullable (and 'allowNull == true') return 'null'
	** 1. If the type is a Map, an empty map is returned
	** 1. If the type is a List, an empty list is returned (with zero capacity)
	** 1. If one exists, a public no-args ctor is called to create the object
	** 1. If it exists, the value of the type's 'defVal' slot is returned
	**    (must be a static field or method with zero params)
	** 1. 'ArgErr' is thrown 
	** 
	** This method differs from [Type.make()]`sys::Type.make` for the following reasons:
	**  - 'null' is returned if type is nullable. 
	**  - Can create Lists and Maps
	**  - The public no-args ctor can be called *anything*. 
	** 
	static Obj? defVal(Type type, Bool allowNull := true) {
		if (type.isNullable && allowNull)
			return null

		if (type.qname == "sys::List") {
			valType := type.params["V"] ?: Obj?#
			list := valType.emptyList.rw
			list.capacity = 0
			return list
		}

		if (type.qname == "sys::Map") {
			mapType := type.isGeneric ? Obj:Obj?# : type
			return Map(mapType.toNonNullable)
		}

		ctors := ReflectUtils.findCtors(type, Type#.emptyList)
		if (ctors.size == 1 && ctors.first.isPublic)
			return ctors.first.call
		
		defValField := ReflectUtils.findField(type, "defVal", null, true)
		if (defValField != null && defValField.isPublic)
			return defValField.get
		
		defValMethod := ReflectUtils.findMethod(type, "defVal", Type#.emptyList, true)
		if (defValMethod != null && defValMethod.isPublic)
			return defValMethod.call

		throw ArgErr("Could not find a defVal for ${type.signature}".replace("sys::", ""))
	}
}
