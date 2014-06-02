
internal const abstract class ExpressionSegment {
	const TypeCoercer	typeCoercer
	const |Type->Obj|	makeFunc 
	const Bool			createIfNull
	
	new make(|This| f) { f(this) }

	Obj? call(Obj instance, Obj?[]? args) {
		makeSegment(instance, true).get(args)
	}
	
	Obj? get (Obj instance, Bool isLast := false) {
		makeSegment(instance, isLast).get(null)
	}

	Void set (Obj instance, Obj? value) {
		makeSegment(instance, true).set(value)
	}

	abstract SegmentExecutor makeSegment(Obj instance, Bool isLast)
}

internal const class SlotSegment : ExpressionSegment {
	const Obj?[]	methodArgs
	const Str 		slotName
	
	new make(Str slotName, Str[]? methodArgs, |This| f) : super(f) {
		this.slotName 	= slotName
		this.methodArgs = methodArgs ?: Str#.emptyList
	}

	override SegmentExecutor makeSegment(Obj instance, Bool isLast) {
		slot := instance.typeof.slot(slotName)
		
		if (slot.isField)
			return ExecuteField(instance, slot) {
				it.typeCoercer 	= this.typeCoercer
				it.createIfNull	= isLast ? false : this.createIfNull
				it.makeFunc		= this.makeFunc
			}

		if (slot.isMethod)
			return ExecuteMethod(instance, slot, methodArgs) {
				it.typeCoercer 	= this.typeCoercer
				it.createIfNull	= isLast ? false : this.createIfNull
				it.makeFunc		= this.makeFunc
			}

		throw Err("WTF!?")
	}
}

internal const class IndexSegment : ExpressionSegment {
	const Int	maxListSize
	const Str	index

	new make(Str index, |This| f) : super(f) {
		this.index	= index
	}

	override SegmentExecutor makeSegment(Obj instance, Bool isLast) {
		ExecuteIndex(instance, index) {
			it.typeCoercer 	= this.typeCoercer
			it.createIfNull	= isLast ? false : this.createIfNull
			it.makeFunc		= this.makeFunc
			it.maxListSize	= this.maxListSize
		}
	}
}

// ---- Executors ---------------------------------------------------------------------------------

internal abstract class SegmentExecutor {
	TypeCoercer?	typeCoercer
	|Type->Obj|?	makeFunc 
	Bool?			createIfNull
	Obj?			instance

	abstract Obj? get(Obj?[]? args)
	abstract Void set(Obj? value)
}

internal class ExecuteField : SegmentExecutor{
	Field		field
	
	new make(Obj instance, Field field, |This| f) {
		f(this)
		this.instance	= instance
		this.field		= field
	}
	
	override Obj? get(Obj?[]? args) {
		if (args != null)
			throw ArgErr(ErrMsgs.property_notMethod(field))

		ret := field.get(instance) 
		if (createIfNull && ret == null) {
			ret = makeFunc(field.type)
			field.set(instance, ret)
		}
		return ret
	}

	override Void set(Obj? value) {
		val := typeCoercer.coerce(value, field.type)
		field.set(instance, val)
	}
}

internal class ExecuteMethod : SegmentExecutor {
	Method		method
	Str[]		methodArgs
	
	new make(Obj instance, Method method, Str[] methodArgs, |This| f) {
		f(this)
		this.instance	= instance
		this.method		= method
		this.methodArgs	= methodArgs
	}
	
	override Obj? get(Obj?[]? args) {
		args = args ?: methodArgs.map |arg, i| { typeCoercer.coerce(arg, method.params[i].type) }
		ret := method.callOn(instance, args)
		return ret
	}

	override Void set(Obj? value) {
		throw ArgErr(ErrMsgs.property_setOnMethod(method))
	}
}

internal class ExecuteIndex : SegmentExecutor {
	Int			maxListSize
	Str			index
	Method		getMethod
	Method		setMethod
	Type		idxType
	Type		valType
	Bool		isList

	new make(Obj instance, Str index, |This| f) {
		f(this)
		type			:= instance.typeof
		this.isList		= false
		this.instance	= instance
		this.index		= index
		this.getMethod	= type.method("get") 
		this.setMethod	= type.method("set")
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
	
	override Obj? get(Obj?[]? args) {
		idx := typeCoercer.coerce(index, idxType)
		
		// if in the middle of an expression, ensure we succeed
		if (isList && createIfNull)
			ensureListSize(instance, idx)
		
		ret := getMethod.callOn(instance, [idx])
		
		// don't return null in the middle of an expression
		if (createIfNull && ret == null) {
			ret = makeFunc(valType)
			setMethod.callOn(instance, [idx, ret])
		}
		return ret
	}
	
	override Void set(Obj? value) {
		idx := typeCoercer.coerce(index, idxType)
		if (isList)
			ensureListSize(instance, idx)
		val := typeCoercer.coerce(value, valType)
		setMethod.callOn(instance, [idx, val])
	}
	
	private Void ensureListSize(Obj?[] list, Int idx) {
		if (list.size <= idx) {
			if (idx > maxListSize)
				throw ArgErr(ErrMsgs.property_crazyList(idx, valType))
			if (valType.isNullable)
				list.size = idx + 1
			else {
				toAdd := idx - list.size + 1
				toAdd.times { list.add(makeFunc(valType)) }
			}
		}
	}
}
