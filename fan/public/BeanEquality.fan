
** Provides 'equals()', 'hash()' and 'toStr()' methods that calculate bean equality based on fields. 
** Sample usage:
** 
** pre>
** syntax: fantom
** 
** class User {
**     Int? id
**     Str? name
**     Str? wotever 
** 
**   override Int hash() {
**     BeanEquality.beanHash(this, [#id, #name])
**   }
**   
**   override Bool equals(Obj? obj) {
**     BeanEquality.beanEquals(this, obj, [#id, #name])
**   }
**   
**   override Str toStr() {
**     BeanEquality.beanToStr(this, [#id, #name])
**   }
** }
** <pre
@Js
mixin BeanEquality {
	
	** Calculates a hash value from the given fields.
	static Int beanHash(Obj objThis, Field[] fields) {
		// see http://stackoverflow.com/questions/113511/hash-code-implementation
		fields.reduce(42) |Int result, field -> Int| {
			(37 * result) + (field.get(objThis) ?: 0).hash
		}
	}

	** Calculates equality based on the given fields.
	static Bool beanEquals(Obj objThis, Obj? obj, Field[] fields) {
		if (!(obj?.typeof?.fits(objThis.typeof) ?: false))
			return false
		
		return fields.all |field -> Bool| {
			field.get(objThis) == field.get(obj) 
		}
	}
	
	** Calculates a Str value from the given fields.
	static Str beanToStr(Obj objThis, Field[] fields) {
		fields.map |field -> Str| {
			"${field.name}=" + (field.get(objThis)?.toStr ?: "null")
		}.join(", ")
	}
}
