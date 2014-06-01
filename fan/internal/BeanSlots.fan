
internal abstract class BeanSlot {
	Slot 			slot
	TypeCoercer? 	typeCoercer
	|Type->Obj|?	makeFunc 
	Bool?			createIfNull
	
	new make(Slot slot) {
		this.slot = slot
	}
	
	Field field() { slot }
	Method method() { slot }

	abstract Obj? get(Obj? instance)
	abstract Void set(Obj? instance, Obj? val)
	abstract Type returns()
}

internal class BeanSlotObjField : BeanSlot {

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

internal class BeanSlotListField : BeanSlot {
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

internal class BeanSlotMapField : BeanSlot {
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

internal class BeanSlotMethod : BeanSlot {
	private Obj?[] args
	
	new make(Method method, Str[] args) : super(method) {
		objs := [,]
		args.each |arg, i| {
			objs.add(typeCoercer.coerce(arg, method.params[i].type))
		}
		this.args = objs
	}
	
	override Obj? get(Obj? instance) {
		method.callOn(instance, args) 
	}

	override Void set(Obj? instance, Obj? value) {
		throw ArgErr(ErrMsgs.property_setOnMethod(method))
	}

	override Type returns() {
		method.returns
	}
}

internal class BeanSlotOperator : BeanSlot {
	private Type type
	private Obj  index
	
	new make(Type type, Obj index) : super(type.method("get")) {
		this.type = type
		this.index = index
	}
	
	override Obj? get(Obj? instance) {
		ret := type.method("get").callOn(instance, [index])
		if (ret == null && createIfNull) {
			ret = returns.make
			set(instance, ret)
		}
		return ret
	}
	
	override Void set(Obj? instance, Obj? value) {
		type.method("set").callOn(instance, [index, value])
	}
	
	override Type returns() {
		type.method("get").returns
	}	
}
