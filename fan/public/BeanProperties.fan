using afPegger

** Does its best attempt to complete the action, be it creating classes along the way, coercing strings to types
class BeanProperties {

	// TODO:
//	static Obj getStaticProperty(Str property, Type type) {
	
	static Obj getProperty(Str property, Obj instance) {
		BeanProperty(instance.typeof, property).get(instance)
	}
	
	static Void setProperty(Str property, Obj instance, Obj? value) {
		BeanProperty(instance.typeof, property).set(instance, value)
	}
	
	static Void setProperties(Str:Obj? propertyValues, Obj instance) {
		propertyValues.each |value, property| {
			BeanProperty(instance.typeof, property).set(instance, value)
		}
	}
}

** Uses the getter and setters
class BeanProperty {
	private BeanField[] beanFields
	
	new make(Type type, Str property) {
		beanFields = BeanFieldFactory.parse(type, property)
	}

	Obj? get(Obj? instance) {
		beanFields.reduce(instance) |inst, bean| { bean.get(inst) }
	}
	
	Void set(Obj? instance, Obj? value) {
		beanFields.eachRange(0..<-1) |bean| { instance = bean.get(instance) }
		beanFields[-1].set(instance, value)
	}
}

internal class BeanFieldFactory : Rules {
	
	static BeanField[] parse(Type type, Str property) {
		beanFields := BeanField[,]
		beanType   := type

		basicField := fieldName	{ 
			it.name = "basicField" 
			it.action = |Match match| {
				field := beanType.field(match.matched)
				beanFields.add(BeanFieldObj(field))
				beanType = beanFields.last.returns 
			}
		}

//		indexName  := oneOrMore(any) { it.name = "indexName" }	// TODO: to dat onlyIfNot
		indexName  := oneOrMore(anyAlphaNum) { it.name = "indexName" }
		indexField := sequence([fieldName, str("["), indexName, str("]")]) { 
			it.name = "indexField" 
			it.action = |Match match| {
				field := beanType.field(match.matches["fieldName"].matched)
				index := match.matches["indexName"].matched
				if (field.type.name == "List")
					beanFields.add(BeanFieldList(field, index.toInt))
				if (field.type.name == "Map")
					beanFields.add(BeanFieldMap(field, index))
				beanType = beanFields.last.returns 
			}
		}
		
		beanField  := sequence([firstOf([indexField, basicField]), optional(str("."))])
//		beanField  := sequence([basicField, optional(str("."))])
		
		parser  := Parser(beanField, property.in)
		matches := parser.parseAll
		
		if (beanFields.isEmpty)
			throw Err(parser.failures.toStr)
		// TODO: just check for failures, full stop!
		
		beanFields.eachRange(0..<-1) { it.createIfNull = true }
		
		return beanFields
	}
	
	private static Rule fieldName() {
		sequence([
			firstOf([str("_"), anyAlpha]), 
			zeroOrMore(firstOf([str("_"), anyAlphaNum]))
		]) { it.name = "fieldName" }
	}
}

internal abstract class BeanField {
	TypeCoercer typeCoercer	:= TypeCoercer()
	Field 		field
	Bool		createIfNull
	
	new make(Field field) {
		this.field = field
	}

	abstract Obj? get(Obj? instance)
	abstract Void set(Obj? instance, Obj? val)
	abstract Type returns()
}

internal class BeanFieldObj : BeanField {

	new make(Field field) : super(field) { }
	
	override Obj? get(Obj? instance) {
		ret := field.get(instance) 
		if (ret == null && createIfNull) {
			ret = returns.make
			field.set(instance, ret)
		}
		return ret
	}

	override Void set(Obj? instance, Obj? value) {
		field.set(instance, typeCoercer.coerce(value, field.type))
	}

	override Type returns() {
		field.type
	}
}

internal class BeanFieldList : BeanField {
	private Int index
	private Type listType
	
	new make(Field field, Int index) : super(field) {
		this.index = index
		this.listType = field.type.params["V"] ?: Obj?#
	}
	
	override Obj? get(Obj? instance) {
		list := (Obj?[]?) field.get(instance) ?: (createIfNull ? makeList(instance) : null)
		if (list == null) return null
		
		ensureSize(list)
		ret := list.get(index)
		if (ret == null && createIfNull) {
			ret = returns.make
			list.set(index, ret)
		}
		return ret
	}
	
	override Void set(Obj? instance, Obj? value) {
		list := (Obj?[]?) field.get(instance) ?: makeList(instance) 
		ensureSize(list)
		list.set(index, typeCoercer.coerce(value, listType))
	}
	
	override Type returns() {
		listType
	}
	
	private Obj?[] makeList(Obj? instance) {
		list := listType.emptyList.rw
		field.set(instance, list)
		return list
	}
	
	private Void ensureSize(Obj?[] list) {
		if (list.size <= index) {
			toAdd := index - list.size + 1
			if (toAdd > 10000)
				// adding 1000 items is mad, but 10,000 is *insane*!
				throw ArgErr(ErrMsgs.property_crazy(index, listType, field))
			if (listType.isNullable)
				list.size = index + 1
			else
				toAdd.times { list.add(listType.make) }
		}
	}
}

internal class BeanFieldMap : BeanField {
	private Obj key
	private Type keyType
	private Type valType
	
	new make(Field field, Obj key) : super(field) {
		this.keyType = field.type.params["K"] ?: Obj#
		this.valType = field.type.params["V"] ?: Obj?#
		this.key	 = typeCoercer.coerce(key, keyType)
	}
	
	override Obj? get(Obj? instance) {
		map := ([Obj:Obj?]?) field.get(instance) ?: (createIfNull ? makeMap(instance) : null)
		if (map == null) return null

		ret := map.get(key)
		if (ret == null && createIfNull) {
			ret = returns.make
			map.set(key, ret)
		}
		return ret
	}
	
	override Void set(Obj? instance, Obj? value) {
		map := ([Obj:Obj?]?) field.get(instance) ?: makeMap(instance)
		map.set(key, typeCoercer.coerce(value, valType))
	}
	
	override Type returns() {
		valType
	}
	
	private Obj:Obj? makeMap(Obj? instance) {
		map := Map(field.type.toNonNullable)
		field.set(instance, map)
		return map
	}
}
