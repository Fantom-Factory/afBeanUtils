
** Creates Lists, Maps and other Objects, optionally setting fields via an it-block ctor. 
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

