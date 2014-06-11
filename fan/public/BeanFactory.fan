
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
		this.ctorArgs = ctorArgs ?: Obj?#.emptyList
		this.ctorPlan = ctorPlan ?: [:]
	}
	
	** Returns a default value for the given type.
	** 
	** The default type is determined by the following algorithm:
	** 1. If the type is nullable, 'null' is returned.
	** 1. If the type is a Map, a read only empty map is returned.
	** 1. If the type is a List, a read only empty list is returned. (With zero capacity.)
	** 1. If one exists, a no-args ctor is called to create the object.
	** 1. If it exists, the value of the type's 'defVal' slot is returned. 
	**    (Must be a static field or a static method with zero params.)
	** 1. 'Err' is thrown. 
	static Obj? defaultValue(Type type) {
		if (type.isNullable)
			return null
		if (type.name == "List" || type.name == "Map")
			return BeanFactory(type).create.toImmutable
		
		ctor := type.methods.find |method| {
			if (!method.isCtor) 
				return false
			if (!method.isPublic) 
				return false
			return (ReflectUtils.paramTypesFitMethodSignature(Obj#.emptyList, method))
		}
		if (ctor != null)
			return ctor.call
		
		defValSlot := type.slot("defVal", false)
		if (defValSlot != null && defValSlot.isPublic && defValSlot.isStatic)
			return defValSlot.isField ? ((Field) defValSlot).get : ((Method) defValSlot).call

		throw Err(ErrMsgs.factory_defValNotFound(type))
	}
	
	** Fantom Bug: http://fantom.org/sidewalk/topic/2163#c13978
	@Operator 
	private Obj? get(Obj key) { null }

	// IoC requires a Str name
	** Adds an item to the it-block ctor plan.
	@Operator
	This set(Str fieldName, Obj? val) {
		field := type.field(fieldName)
		ctorPlan[field] = val
		return this
	}

	** Creates the object.
	Obj create() {
		// TODO: oneshot lock

		if (type.name == "List") {
			valType := type.params["V"] ?: Obj?#
			return valType.emptyList.rw
		}

		if (type.name == "Map") {
			mapType := type.isGeneric ? Obj:Obj?# : type
			return Map(mapType.toNonNullable)
		}

		args := ctorPlan.isEmpty ? (ctorArgs.isEmpty ? null : ctorArgs) : ctorArgs.dup.add(Field.makeSetFunc(ctorPlan))
		return type.make(args)
	}
}

