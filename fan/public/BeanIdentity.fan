
**
** pre>
** class User {
**   @BeanId Int id
**   @BeanId Str name
** 
**   override Int hash() {
**     BeanIdentity.beanHash(this)
**   }
**   
**   override Bool equals(Obj? obj) {
**     BeanIdentity.beanEquals(this, obj)
**   }
**   
**   override Str toStr() {
**     BeanIdentity.beanToStr(this)
**   }
** }
** <pre
const class BeanIdentity {
	
	static Int beanHash(Obj objThis) {
		beanIdFields(objThis)
			.findAll { beanId(it).useInHash }
			// see http://stackoverflow.com/questions/113511/hash-code-implementation
			.reduce(42) |Int result, field -> Int| {
				return (37 * result) + (field.get(objThis) ?: 0).hash
			}
	}

	static Bool beanEquals(Obj objThis, Obj? obj) {
		if (!(obj?.typeof?.fits(objThis.typeof) ?: false))
			return false
		
		return beanIdFields(obj)
			.findAll { beanId(it).useInEquals }
			.all |field -> Bool| {
				field.get(objThis) == field.get(obj) 
			}
	}
	
	static Str beanToStr(Obj objThis) {
		beanIdFields(objThis)
			.findAll { beanId(it).useInToStr }
			.map |field -> Str| {
				"${field.name}=" + (field.get(objThis)?.toStr ?: "null")
			}
			.join(", ")
	}

	private static Field[] beanIdFields(Obj obj) {
		obj.typeof.fields.findAll { it.hasFacet(BeanId#) }
	}

	private static BeanId beanId(Field field) {
		Field#.method("facet").callOn(field, [BeanId#]) // Stoopid F4
	}
}

facet class BeanId {
	const Bool useInEquals	:= true
	const Bool useInHash	:= true
	const Bool useInToStr	:= true
}