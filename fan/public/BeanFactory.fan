
** Creates Lists, Maps and other Objects, optionally setting field values.
** Ctors may be of any scope: 'public', 'protected', 'internal' and even 'private'.
** 
** Fields are either set post construction or via an it-block ctor argument 
** (which must be the last method parameter). 
** 
** 'const' types **must** provide an it-block ctor if fields are to be set. 
** 
** Bean factory instances may only be used the once. 
@Js
class BeanFactory {
	
	** The type this factory will create 
	Type type {
		private set
	}

	private OneShotLock		createLock	:= OneShotLock("Factory has been used")
	@NoDoc
	protected Obj?[]		ctorArgs
 	@NoDoc
	protected Field:Obj? 	fieldVals
	
	** Makes a factory for the given type.
	new make(Type type, Obj?[]? ctorArgs := null, [Field:Obj?]? fieldVals := null) {
		this.type = type
		this.ctorArgs  = ctorArgs  ?: Obj?#.emptyList.rw
		this.fieldVals = fieldVals ?: Field:Obj?[:]
	}
	
	** Fantom Bug: `http://fantom.org/sidewalk/topic/2163#c13978`
	@Operator 
	private Obj? get(Obj key) { null }

	** Sets a field on the type to be instantiated.
	@Operator
	This set(Field field, Obj? val) {
		createLock.check
		if (!type.fits(field.parent))
			throw ArgErr(ErrMsgs.factory_fieldWrongParent(type, field))
		fieldVals[field] = val
		return this
	}

	** Sets a field on the type to be instantiated.
	This setByName(Str fieldName, Obj? val) {
		createLock.check
		field := type.field(fieldName)
		return set(field, val)
	}

	** Adds a ctor argument.
	@Operator
	This add(Obj? arg) {
		createLock.check
		ctorArgs.add(arg)
		return this
	}

	** Creates an instance of the object, optionally using the given ctor.
	** 
	** If no ctor is given, a suitable one is picked that matches the arguments accumulated by the factory. 
	Obj create(Method? ctor := null) {
		createLock.lock

		if (ctor!= null && ctor.parent != type)
			throw ArgErr(ErrMsgs.factory_ctorWrongType(type, ctor))
		
		return doCreate(ctor)
	}
	
	@NoDoc
	protected virtual Obj doCreate(Method? ctor := null) {
		
		// if there is nothing to set, try our luck at a default value
		// needed for Ints, Strs, Lists and Maps, etc...
		if (ctor == null && ctorArgs.isEmpty) {
			defVal := makeFromDefaultValue(type)
			if (defVal != null)
				return setFieldVals(defVal)
		}

		args := ctorArgs

		if (ctor != null) {
			if (!ctor.params.isEmpty && ctor.params[-1].type.fits(|This|#) && args.size == (ctor.params.size - 1)) {
				itBlockFunc := Field.makeSetFunc(fieldVals.dup) 	// that .dup() is very important!
				args.add(itBlockFunc)
				fieldVals.clear
			}

			argTypes := args.map { it?.typeof }
			if (!ReflectUtils.argTypesFitMethod(argTypes, ctor) || args.size > ctor.params.size)
				throw Err(ErrMsgs.factory_ctorArgMismatch(ctor, args))
			
			return setFieldVals(ctor.callList(args))
		}

		// look for ctors that may / or may not take an it-block, favouring those that do
		itBlockFunc		:= Field.makeSetFunc(fieldVals.dup) 	// that .dup() is very important!
		argsWithOut		:= ctorArgs
		argsWith		:= ctorArgs.dup.add(itBlockFunc)
		argTypesWithOut	:= argsWithOut.map { it?.typeof }
		argTypesWith	:= argsWith   .map { it?.typeof }
		ctorsWithOut	:= ReflectUtils.findCtors(type, argTypesWithOut).exclude { argsWithOut.size > it.params.size }
		ctorsWith		:= ReflectUtils.findCtors(type, argTypesWith   ).exclude { argsWith.size    > it.params.size }
		ctorsBoth		:= ctorsWithOut.dup.addAll(ctorsWith).unique
		
		if (ctorsWithOut.isEmpty && ctorsWith.isEmpty)
			throw Err(ErrMsgs.factory_noCtorsFound(type, argTypesWithOut))
		if (ctorsBoth.size > 1 && ctorsWith.size != 1)	// favour ctors with it-blocks
			throw Err(ErrMsgs.factory_tooManyCtorsFound(type, ctorsBoth.map { it.name }, argTypesWithOut))
		
		if (ctorsWith.size == 1) {
			ctor = ctorsWith.first
			args = argsWith
			fieldVals.clear
		} else {
			ctor = ctorsWithOut.first
			args = argsWithOut
		}
		
		return setFieldVals(ctor.callList(args))		
	}
	
	@NoDoc
	override Str toStr() {
		"BeanFactory for $type.qname"
	}
	
	** Returns a default value for the given type. 
	** Use as a replacement for [Type.make()]`sys::Type.make`.
	** 
	** Returned objects are *not* guaranteed to be immutable. 
	** Call 'toImmutable()' on returned object if you need 'const' Lists and Maps.
	** 
	** The default type is determined by the following algorithm:
	** 1. If the type is nullable (and 'force == false') return 'null'.
	** 1. If the type is a Map, an empty map is returned.
	** 1. If the type is a List, an empty list is returned. (With zero capacity.)
	** 1. If one exists, a public no-args ctor is called to create the object.
	** 1. If it exists, the value of the type's 'defVal' slot is returned. 
	**    (Must be a static field or a static method with zero params.)
	** 1. 'ArgErr' is thrown. 
	** 
	** This method differs from [Type.make()]`sys::Type.make` for the following reasons:
	**  - 'null' is returned if type is nullable. 
	**  - Can create Lists and Maps
	**  - The public no-args ctor can be called *anything*. 
	static Obj? defaultValue(Type type, Bool force := false) {
		if (type.isNullable && !force)
			return null

		return makeFromDefaultValue(type) ?: throw ArgErr(ErrMsgs.factory_defValNotFound(type)) 
	}

	@NoDoc
	protected static Obj? makeFromDefaultValue(Type type) {
		if (type.name == "List") {
			valType := type.params["V"] ?: Obj?#
			list := valType.emptyList.rw
			list.capacity = 0
			return list
		}

		if (type.name == "Map") {
			mapType := type.isGeneric ? Obj:Obj?# : type
			return Map(mapType.toNonNullable)
		}

		ctors := ReflectUtils.findCtors(type)
		if (ctors.size == 1 && ctors.first.isPublic)
			return ctors.first.call
		
		defValField := ReflectUtils.findField(type, "defVal", null, true)
		if (defValField != null && defValField.isPublic)
			return defValField.get
		
		defValMethod := ReflectUtils.findMethod(type, "defVal", Type#.emptyList, true)
		if (defValMethod != null && defValMethod.isPublic)
			return defValMethod.call

		return null
	}

	private Obj? setFieldVals(Obj? obj) {
		fieldVals.each |val, field| {
			field.set(obj, val)
		}
		return obj
	}	
}
