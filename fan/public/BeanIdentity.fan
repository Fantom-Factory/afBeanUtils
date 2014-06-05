
** 'equals()', 'hash()' and 'toStr()' methods using fields annotated with `BeanId`. 
** Sample usage:
** 
** pre>
** class User {
**   @BeanId Int? id
**   @BeanId Str? name
**           Str? notUsed 
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
** 
** @see `BeanId`
@Js
const class BeanIdentity {
	
	** Calculates a hash value from 'BeanId' fields.
	static Int beanHash(Obj objThis) {
		beanIdFields(objThis)
			.findAll { beanId(it).useInHash }
			// see http://stackoverflow.com/questions/113511/hash-code-implementation
			.reduce(42) |Int result, field -> Int| {
				return (37 * result) + (field.get(objThis) ?: 0).hash
			}
	}

	** Calculates equality based on 'BeanId' fields.
	static Bool beanEquals(Obj objThis, Obj? obj) {
		if (!(obj?.typeof?.fits(objThis.typeof) ?: false))
			return false
		
		return beanIdFields(obj)
			.findAll { beanId(it).useInEquals }
			.all |field -> Bool| {
				field.get(objThis) == field.get(obj) 
			}
	}
	
	** Calculates a Str value from 'BeanId' fields.
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

** Place on fields to mark them as being important to the object's identity.
** 
** Sample usage:
** pre>
** class User {
**   @BeanId Int? id
**   @BeanId Str? name
**           Str? notUsed 
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
** 
** @see `BeanIdentity`
@Js
facet class BeanId {
	const Bool useInEquals	:= true
	const Bool useInHash	:= true
	const Bool useInToStr	:= true
}
