
** Can't be 'const' 'cos method args may not be const.
internal abstract class BeanSlot {
	TypeCoercer? 	typeCoercer
	|Type->Obj|?	makeFunc 
	Bool			createIfNull
	
	abstract Obj? get(Obj? instance)
	abstract Void set(Obj? instance, Obj? val)
	abstract Type returns()
}

internal class BeanSlotField : BeanSlot {
	private Field field
	
	new make(Field field, |BeanSlot| f) {
		f(this)
		this.field = field
	}
	
	override Obj? get(Obj? instance) {
		ret := field.get(instance) 
		if (ret == null && createIfNull) {
			ret = makeFunc(returns)
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

internal class BeanSlotMethod : BeanSlot {
	Obj?[] args
	private Method method
	
	new make(Method method, Str[] args, |BeanSlot| f) {
		f(this)
		this.method = method
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

internal class BeanSlotList : BeanSlot {
	private Int index
	private Type valType
	
	new make(Type listType, Str index, |BeanSlot| f) {
		f(this)
		this.valType = listType.params["V"] ?: Obj?#
		this.index   = index.toInt
	}
	
	override Obj? get(Obj? instance) {
		list := (Obj?[]) instance	// should never be null
		
		// if in the middle of an expression, ensure we succeed
		if (createIfNull)
			ensureSize(list)
		
		ret := list.get(index)
		
		// don't return null in the middle of an expression
		if (createIfNull && ret == null) {
			ret = makeFunc(returns)
			list.set(index, ret)
		}

		return ret
	}
	
	override Void set(Obj? instance, Obj? value) {
		list := (Obj?[]) instance	// should never be null

		ensureSize(list)
		list.set(index, typeCoercer.coerce(value, valType))
	}
	
	override Type returns() {
		valType
	}
	
	private Void ensureSize(Obj?[] list) {
		if (list.size <= index) {
			toAdd := index - list.size + 1
			if (toAdd > 10000)
				// adding 1000 items is mad, but 10,000 is *insane*!
				throw ArgErr(ErrMsgs.property_crazy(index, valType))
			if (valType.isNullable)
				list.size = index + 1
			else
				toAdd.times { list.add(makeFunc(returns)) }
		}
	}
}

internal class BeanSlotMap : BeanSlot {
	private Obj key
	private Type keyType
	private Type valType
	
	new make(Type mapType, Obj key, |BeanSlot| f) {
		f(this)
		this.keyType = mapType.params["K"] ?: Obj#
		this.valType = mapType.params["V"] ?: Obj?#
		this.key	 = typeCoercer.coerce(key, keyType)
	}
	
	override Obj? get(Obj? instance) {
		map := (Obj:Obj?) instance	// should never be null

		ret := map.get(key)

		// don't return null in the middle of an expression
		if (createIfNull && ret == null) {
			ret = makeFunc(returns)
			map.set(key, ret)
		}

		return ret
	}
	
	override Void set(Obj? instance, Obj? value) {
		map := (Obj:Obj?) instance	// should never be null
		map.set(key, typeCoercer.coerce(value, valType))
	}
	
	override Type returns() {
		valType
	}
}

internal class BeanSlotOperator : BeanSlot {
	private Type type
	private Obj  index
	
	new make(Type type, Obj index, |BeanSlot| f) {
		f(this)
		this.type  = type
		this.index = index
	}
	
	override Obj? get(Obj? instance) {
		ret := type.method("get").callOn(instance, [index])
		
		// don't return null in the middle of an expression
		if (createIfNull && ret == null) {
			ret = makeFunc(returns)
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
