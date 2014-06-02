
//Do that ctor plan
//
//have a clone method
// make like IoC.autobuild

** Creates Lists, Maps and other Objects, optionally setting fields via an it-block ctor. 
class BeanFactory {
	Type type {
		private set
	}
	
	new make(Type type) {
		this.type = type
	}
	
	Obj create() {
		if (type.name == "List") {
			valType := type.params["V"] ?: Obj?#
			return valType.emptyList.rw
		}

		if (type.name == "Map") {
			mapType := type.isGeneric ? Obj:Obj?# : type
			return Map(mapType.toNonNullable)
		}

		return type.make
	}
}

