
** Creates Lists, Maps and other Objects, optionally setting field values.
** Ctors may be of any scope: 'public', 'protected', 'internal' and even 'private'.
** 
** Fields are either set post construction or via an it-block ctor argument 
** (which must be the last method parameter). 
** 
** 'const' types **must** provide an it-block ctor if fields are to be set. 
@Js @Deprecated { msg="Use BeanBuilder instead" }
class BeanFactory {

	// Note: Where this class was nice, it's a lot of overhead to create() a single type
	// Common use-cases are now clear so the simplier BeanBuilder is much cleaner and quicker. 
	
	** The type this factory will create 
	Type type {
		private set	// keep this as non-const to keep binary backwards compatibility
	}

	@NoDoc
	protected Obj?[]		ctorArgs
 	@NoDoc
	protected Field:Obj? 	fieldVals
	
	** Makes a factory for the given type.
	new make(Type type, Obj?[]? ctorArgs := null, [Field:Obj?]? fieldVals := null) {
		this.type = type
		this.ctorArgs	= ctorArgs  ?: Obj?#.emptyList.rw
		this.fieldVals	= fieldVals ?: Field:Obj?[:]
	}
	
	** Fantom Bug: `http://fantom.org/sidewalk/topic/2163#c13978`
	@Operator 
	private Obj? get(Obj key) { null }

	** Sets a field on the type to be instantiated.
	@Operator
	This set(Field field, Obj? val) {
		if (!type.fits(field.parent))
			throw ArgErr("Field ${field.qname} does not belong to ${type.qname}".replace("sys::", ""))
		fieldVals[field] = val
		return this
	}

	** Sets a field on the type to be instantiated.
	This setByName(Str fieldName, Obj? val) {
		field := type.field(fieldName)
		return set(field, val)
	}

	** Adds a ctor argument.
	@Operator
	This add(Obj? arg) {
		ctorArgs.add(arg)
		return this
	}

	** Creates an instance of the object, optionally using the given ctor.
	** 
	** If no ctor is given, a suitable one is picked that matches the arguments accumulated by the factory. 
	Obj create(Method? ctor := null) {
		if (ctor != null && ctor.parent != type)
			throw ArgErr("Ctor ${ctor.qname} does not belong to $type.qname".replace("sys::", ""))
		
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
				throw Err(msg_ctorArgMismatch(ctor, args))
			
			return setFieldVals(ctor.callList(args))
		}

		// look for ctors that may / or may not take an it-block, favouring those that do
		itBlockFunc		:= Field.makeSetFunc(fieldVals.dup) 	// that .dup() is very important!
		argsWithOut		:= ctorArgs
		argsWith		:= ctorArgs.dup.add(itBlockFunc)
		argTypesWithOut	:= (Type[]) argsWithOut.map { it?.typeof }
		argTypesWith	:= (Type[]) argsWith   .map { it?.typeof }
		ctorsWithOut	:= ReflectUtils.findCtors(type, argTypesWithOut).exclude { argsWithOut.size > it.params.size }
		ctorsWith		:= ReflectUtils.findCtors(type, argTypesWith   ).exclude { argsWith.size    > it.params.size }
		ctorsBoth		:= ctorsWithOut.dup.addAll(ctorsWith).unique
		
		if (ctorsWithOut.isEmpty && ctorsWith.isEmpty)
			throw Err("Could not find a ctor on ${type.qname} to match argument types - ${argTypesWithOut}".replace("sys::", ""))
		if (ctorsBoth.size > 1 && ctorsWith.size != 1)	// favour ctors with it-blocks
			throw Err(msg_tooManyCtorsFound(type, ctorsBoth.map { it.name }, argTypesWithOut))
		
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
	** 1. If the type is nullable (and 'force == false') return 'null'
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
	static Obj? defaultValue(Type type, Bool force := false) {
		if (type.isNullable && !force)
			return null

		return makeFromDefaultValue(type) ?: throw ArgErr("${type.signature} is null and does not have a default value".replace("sys::", "")) 
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

		ctors := ReflectUtils.findCtors(type, Type#.emptyList)
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
	
	private static Str msg_ctorArgMismatch(Method ctor, Obj?[] args) {
		ctorSig := ctor.qname + "(" + ctor.params.join(", ") + ")"
		return "Arguments do not match ctor params for ${ctorSig} - ${args}".replace("sys::", "")
	}

	private static Str msg_tooManyCtorsFound(Type type, Str[] ctorNames, Type?[] argTypes) {
		"Found more than 1 ctor on ${type.qname} ${ctorNames} that match argument types - ${argTypes}".replace("sys::", "")
	}
}
