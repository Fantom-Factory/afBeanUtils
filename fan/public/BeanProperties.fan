
** Does its best attempt to complete the action, be it creating classes along the way, coercing strings to types
** 
** Static typing, all Maps, Lists and methods must be correctly defined with return types 
** 
** Can't use -> dynamic calls as need to know if it's field or a method
class BeanProperties {

	// Bad idea, static values are const! (Okay, well, thread safe - but they rarely change anyhow.)
	// static Obj getStaticProperty(Type type, Str property) { ... }
	
	** Similar to 'get()' but may read better in code if you know the expression ends with a method.
	** 
	** Any arguments given overwrite arguments in the expression. Example:
	** 
	**   BeanProperties.call(Buf(), "fill(255, 4)", [128, 2])  // --> 0x8080
	static Obj call(Obj instance, Str property, Obj?[]? args := null) {
		BeanPropertyFactory().parse(instance.typeof, property).call(instance, args)
	}

	** Gets the value of the field (or method) at the end of the property expression.
	static Obj? get(Obj instance, Str property) {
		BeanPropertyFactory().parse(instance.typeof, property).get(instance)
	}
	
	** Sets the value of the field at the end of the property expression.
	static Void set(Obj instance, Str property, Obj? value) {
		BeanPropertyFactory().parse(instance.typeof, property).set(instance, value)
	}
	
	** Given a map of values, keyed by property expressions, this sets them on the given instance.
	static Void setAll(Obj instance, Str:Obj? propertyValues) {
		factory := BeanPropertyFactory()
		propertyValues.each |value, property| {
			factory.parse(instance.typeof, property).set(instance, value)
		}
	}
}

** Parses property expressions to create 'BeanProperty' instances. 
@NoDoc
class BeanPropertyFactory {
	
	// Fantex test string: obj.list[2].map[wot][thing].meth(judge, dredd).str().prop
	private static const Regex	slotRegex	:= Regex<|(?:([^\.\[\]\(\)]*)(?:\(([^\)]+)\))?)?(?:\[([^\]]+)\])?|>
	
	** Given to 'BeanProperties' to convert Str values into objects. 
	** Supplied so you may substitute it with a cached version. 
	TypeCoercer 	typeCoercer	 := TypeCoercer()
	
	** Given to 'BeanProperties' to create new instances of intermediate objects.
	** Supplied so you may substitute it with one that injects IoC values.
	** 
	** Only used if 'createIfNull' is 'true'. 
	** 
	** Defaults to '|Type type->Obj| { BeanFactory(type).create }'
	|Type->Obj|		makeFunc 	 := |Type type->Obj| { BeanFactory(type).create }

	** Given to 'BeanProperties' to indicate if they should create new object instances when traversing an expression.
	** If an a new instance is *not* created then a 'NullErr' will occur.
	** 
	** For example, in the expression 'a.b.c', should 'b' be null then a new instance is created and set. 
	** This also applies when setting instances in a 'List' where the List size is less than the index.
	** 
	** Defaults to 'true'
	Bool			createIfNull := true
	
	** Parses a property expression stemming from the given type to produce a 'BeanProperty' that can be used to get / set / call the value at the end. 
	BeanProperty parse(Type type, Str property) {
		beanSlots	:= BeanSlot[,]
		beanType	:= type
				
		f := |BeanSlot bs| { bs.typeCoercer = this.typeCoercer; bs.makeFunc = this.makeFunc }

		matcher	:= slotRegex.matcher(property)
		while (matcher.find) {
			if (matcher.group(0).isEmpty)
				continue

			slotName	:= matcher.group(1)
			methodArgs	:= matcher.group(2)?.split(',', true)
			indexName	:= matcher.group(3)
			beanSlot 	:= (BeanSlot?) null

			if (!slotName.isEmpty) {
				slot := beanType.slot(slotName)

				if (slot.isField && methodArgs != null)
					throw ArgErr("Field ${slot.qname} cannot take method arguments: ${property}")
				
				if (slot.isField)
					beanSlot = BeanSlotField(slot, f)
				if (slot.isMethod)
					beanSlot = BeanSlotMethod(slot, methodArgs ?: Obj?#.emptyList, f)

				beanSlots.add(beanSlot)
				beanType = beanSlot.returns
			}
			
			if (indexName != null) {
				Env.cur.err.printLine(beanType.name)
				if (beanType.name == "List")
					beanSlot = BeanSlotList(beanType, indexName, f)
				else
				if (beanType.name == "Map")
					beanSlot = BeanSlotMap(beanType, indexName, f)
				else
					beanSlot = BeanSlotOperator(beanType, indexName, f)
				beanSlots.add(beanSlot)
				beanType = beanSlot.returns				
			}
		}

		if (beanSlots.isEmpty)
			throw Err(ErrMsgs.property_badParse(property))		
		
		if (createIfNull)
			beanSlots.eachRange(0..<-1) { it.createIfNull = true }
		
		return BeanProperty(property, beanSlots)
	}
}

** Calls methods and gets and sets fields at the end of a property expression.
** Property expressions may traverse lists, maps and methods.
** All field are accessed through their respective getter and setters.
** 
** Use `BeanPropertyFactory` to create instances of 'BeanProperty'.
@NoDoc
class BeanProperty {
	
	** The property expression that this class ultimately calls. 
	Str expression {
		private set
	}
	
	private BeanSlot[] beanSlots
	
	internal new make(Str expression, BeanSlot[] beanSlots) {
		this.expression = expression
		this.beanSlots = beanSlots
	}

	** Similar to 'get()' but may read better in code if you know the expression ends with a method.
	** 
	** Any arguments given overwrite arguments in the expression. Example:
	** 
	**   BeanProperties.call(Buf(), "fill(255, 4)", [128, 2])  // --> 0x8080
	Obj? call(Obj? instance, Obj?[]? args := null) {
		if (args != null) {
			if (beanSlots[-1] isnot BeanSlotMethod)
				throw ArgErr(ErrMsgs.property_notMethod(expression))
			
			beanSlot := (BeanSlotMethod) beanSlots[-1]
			origArgs := beanSlot.args
			try {
				beanSlot.args = args
				return get(instance)
			} finally
			beanSlot.args = origArgs
		}
		return get(instance)
	}
	
	** Gets the value of the field (or method) at the end of the property expression.
	@Operator
	Obj? get(Obj? instance) {
		beanSlots.reduce(instance) |inst, bean| { bean.get(inst) }
	}
	
	** Sets the value of the field at the end of the property expression.
	@Operator
	Void set(Obj? instance, Obj? value) {
		beanSlots.eachRange(0..<-1) |bean| { instance = bean.get(instance) }
		beanSlots[-1].set(instance, value)
	}
}
