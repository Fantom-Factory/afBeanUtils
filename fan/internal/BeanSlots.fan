
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
	
	new make(Field field, |This| f) {
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
	
	new make(Method method, Str[] args, |This| f) {
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

internal class BeanSlotIndexed : BeanSlot {
			Int		maxListSize
	private Method	getMethod
	private Method	setMethod
	private Type	idxType
	private Type	valType
	private Str		index
	private Bool	isList

	new make(Type type, Str index, |This| f) {
		f(this)
		this.getMethod	= type.method("get") 
		this.setMethod	= type.method("set")
		this.index		= index
		
		if (type.name == "List") {
			this.isList		= true
			this.idxType 	= Int#
			this.valType 	= type.params["V"] ?: Obj?#			
		} else
		if (type.name == "Map") {
			this.idxType 	= type.params["K"] ?: Obj#
			this.valType 	= type.params["V"] ?: Obj?#			
		}
		else {
			this.idxType 	= getMethod.params.first.type
			this.valType	= getMethod.returns			
		}
	}
	
	override Obj? get(Obj? instance) {
		idx := typeCoercer.coerce(index, idxType)
		
		// if in the middle of an expression, ensure we succeed
		if (isList && createIfNull)
			ensureListSize(instance, idx)
		
		ret := getMethod.callOn(instance, [idx])
		
		// don't return null in the middle of an expression
		if (createIfNull && ret == null) {
			ret = makeFunc(returns)
			setMethod.callOn(instance, [idx, ret])
		}

		return ret
	}
	
	override Void set(Obj? instance, Obj? value) {
		idx := typeCoercer.coerce(index, idxType)
		if (isList)
			ensureListSize(instance, idx)
		val := typeCoercer.coerce(value, valType)
		setMethod.callOn(instance, [idx, val])
	}
	
	override Type returns() {
		valType
	}
	
	private Void ensureListSize(Obj?[] list, Int idx) {
		if (list.size <= idx) {
			if (idx > maxListSize)
				throw ArgErr(ErrMsgs.property_crazyList(idx, valType))
			if (valType.isNullable)
				list.size = idx + 1
			else {
				toAdd := idx - list.size + 1
				toAdd.times { list.add(makeFunc(returns)) }
			}
		}
	}
}
