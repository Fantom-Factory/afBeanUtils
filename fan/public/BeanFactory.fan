
** Creates Lists, Maps and other Objects, optionally setting fields via an it-block ctor. 
@Js
internal class BeanFactory {
	
	** The type this factory will create 
	Type type {
		private set
	}
	
	private Obj?[]? 	ctorArgs
	private Field:Obj? 	ctorPlan
	
	new make(Type type, Obj?[]? ctorArgs := null, [Field:Obj?]? ctorPlan := null) {
		this.type = type
		this.ctorArgs = ctorArgs ?: Obj?#.emptyList.rw
		this.ctorPlan = ctorPlan ?: [:]
	}
	
	** Fantom Bug: http://fantom.org/sidewalk/topic/2163#c13978
	@Operator 
	private Obj? get(Obj key) { null }

//	** Sets a field on the type to be instantiated.
//	@Operator
//	This set(Field field, Obj? val) {
//		ctorPlan[field] = val
//		return this
//	}
//
//	** Sets a field on the type to be instantiated.
//	This setByName(Str fieldName, Obj? val) {
//		field := type.field(fieldName)
//		return set(field, val)
//	}

	** Adds a ctor argument.
	@Operator
	This add(Obj? arg) {
		ctorArgs.add(arg)
		return this
	}

	** Creates an instance of the object, optionally using the given ctor.
	Obj create(Method? ctor := null) {
		if (ctor!= null && ctor.parent != type)
			throw ArgErr(ErrMsgs.factory_ctorWrongType(type, ctor))

		if (type.name == "List" && ctorArgs.isEmpty && ctorPlan.isEmpty && ctor == null) {
			valType := type.params["V"] ?: Obj?#
			return valType.emptyList.rw
		}

		if (type.name == "Map" && ctorArgs.isEmpty && ctorPlan.isEmpty && ctor == null) {
			mapType := type.isGeneric ? Obj:Obj?# : type
			return Map(mapType.toNonNullable)
		}
		
		args 		:= ctorArgs.dup
		argTypes	:= args.map { it?.typeof }

		if (ctor != null) {
			if (!ReflectUtils.paramTypesFitMethodSignature(argTypes, ctor) || args.size > ctor.params.size)
				throw Err(ErrMsgs.factory_ctorArgMismatch(ctor, args))
		} else {
			ctors := ReflectUtils.findCtors(type, argTypes).exclude { args.size > it.params.size  }
			if (ctors.isEmpty)
				throw Err(ErrMsgs.factory_noCtorsFound(type, argTypes))
			if (ctors.size > 1)
				throw Err(ErrMsgs.factory_tooManyCtorsFound(type, ctors.map { it.name }, argTypes))
			ctor = ctors.first
		}
		
		return ctor.callList(args)
	}
	
	** Returns a default value for the given type. 
	** Use as a replacement for [Type.make()]`Type.make`.
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
	** 1. 'Err' is thrown. 
	static Obj? defaultValue(Type type, Bool force := false) {
		if (type.isNullable && !force)
			return null

		if (type.name == "List" || type.name == "Map")
			return BeanFactory(type).create
		
		ctors := ReflectUtils.findCtors(type)
		if (ctors.size == 1 && ctors.first.isPublic)
			return ctors.first.call
		
		defValField := ReflectUtils.findField(type, "defVal", null, true)
		if (defValField != null && defValField.isPublic)
			return defValField.get
		
		defValMethod := ReflectUtils.findMethod(type, "defVal", Type#.emptyList, true)
		if (defValMethod != null && defValMethod.isPublic)
			return defValMethod.call

		throw Err(ErrMsgs.factory_defValNotFound(type))
	}
}

