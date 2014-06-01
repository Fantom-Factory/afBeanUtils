
** Coerces objects to a given type via 'fromXXX()' / 'toXXX()' ctors and methods.
** This is often useful for converting objects to and from Strs, but can be used for much more. 
** 
** TODO: mention maps and lists
** 'TypeCoercer' recognises type parameters in Lists and Maps and will convert the content of each to 
** 
** 'caseInsensitive' and 'ordered' attributes of new maps are preserved.
** 
** If performance is required, then use [Concurrent]`http://www.fantomfactory.org/pods/afConcurrent` 
** to create a 'TypeCoercer' that caches the functions used to convert between one type and another. 
** Full code for a 'CachedTypeCoercer' is given below: 
** 
** pre>
** using afBeanUtils
** using afConcurrent
** 
** ** A 'TypeCoercer' that caches its conversion methods.
** const class CachingTypeCoercer : TypeCoercer {
**    private const AtomicMap cache := AtomicMap()
** 
**    ** Cache the conversion methods
**    override protected |Obj->Obj|? coerceMethod(Type fromType, Type toType) {
**       key   := "${fromType.qname}->${toType.qname}"
**       return cache.getOrAdd(key) { lookupMethod(fromType, toType) } 
**    }
** 
**    ** Clears the lookup cache 
**    Void clearCache() {
**       cache.clear
**    }
** }
** <pre
const class TypeCoercer {
	
	** Returns 'true' if 'fromType' can be coerced to the given 'toType'.
	Bool canCoerce(Type fromType, Type toType) {
		if (fromType.name == "List" && toType.name == "List") 
			return coerceMethod(fromType.params["V"], toType.params["V"]) != null
		return coerceMethod(fromType, toType) != null
	}
	
	** Coerces the Obj to the given type. 
	** Coercion methods are looked up in the following order:
	**  1. 'toXXX()'
	**  2. 'fromXXX()'
	**  3. 'makeFromXXX()' 
	Obj? coerce(Obj? value, Type toType) {
		if (value == null) 
			return toType.isNullable ? null : throw ArgErr(ErrMsgs.typeCoercer_notFound(null, toType))

		if (value.typeof.name == "List" && toType.name == "List") {
			toListType 	:= toType.params["V"]
			toList 		:= (Obj?[]) toListType.emptyList.rw
			((List) value).each {
				toList.add(coerce(it, toListType))
			}
			return toList
		}

		if (value.typeof.name == "Map" && toType.name == "Map") {
			toKeyType := toType.params["K"]
			toValType := toType.params["V"]
			toMap	  := ([Obj:Obj?]?) null
			
			if (((Map) value).caseInsensitive && toKeyType.fits(Str#))
				toMap	 = Map.make(toType) { caseInsensitive = true }
			if (((Map) value).ordered)
				toMap	 = Map.make(toType) { ordered = true }
			if (toMap == null)
				toMap	 = Map.make(toType)

			((Map) value).each |v1, k1| {
				k2	:= coerce(k1, toKeyType)
				v2	:= coerce(v1, toValType)
				toMap[k2] = v2
			}
			return toMap
		}

		meth := coerceMethod(value.typeof, toType)
		
		if (meth == null)
			throw ArgErr(ErrMsgs.typeCoercer_notFound(value.typeof, toType))

		try {
			return meth(value)
		} catch (Err e) {
			throw ArgErr(ErrMsgs.typeCoercer_fail(value.typeof, toType), e)
		}
	}
	
	** Override this method should you wish to cache the conversion functions. 
	@NoDoc
	protected virtual |Obj->Obj|? coerceMethod(Type fromType, Type toType) {
		lookupMethod(fromType, toType)
	}

	** This method kinda sucks, but it's a workaround.
	** @see http://fantom.org/sidewalk/topic/2289
	@NoDoc
	protected virtual |Obj->Obj|? lookupMethod(Type fromType, Type toType) {
		// check the basics first!
		if (fromType.fits(toType))
			return |Obj val -> Obj| { val }

		// first look for a 'toXXX()' instance method
		toName		:= "to${toType.name}" 
		toXxxMeth 	:= ReflectUtils.findMethod(fromType, toName, Obj#.emptyList, false, toType)
		if (toXxxMeth != null)
			return |Obj val -> Obj| { toXxxMeth.callOn(val, null) }

		// next look for a 'fromXXX()' static / ctor
		// see http://fantom.org/sidewalk/topic/2154
		fromName	:= "from${fromType.name}" 
		fromXxxMeth	:= ReflectUtils.findMethod(toType, fromName, [fromType], true)
		if (fromXxxMeth != null)
			return (|Obj val -> Obj| { fromXxxMeth.call(val) }).toImmutable
		fromXxxCtor := ReflectUtils.findCtor(toType, fromName, [fromType])
		if (fromXxxCtor != null)
			return (|Obj val -> Obj| { fromXxxCtor.call(val) }).toImmutable
				
		// one last chance - try 'makeFromXXX()' ctors
		makefromName	:= "makeFrom${fromType.name}" 
		makeFromXxxMeth	:= ReflectUtils.findMethod(toType, makefromName, [fromType], true)
		if (makeFromXxxMeth != null)
			return |Obj val -> Obj| { makeFromXxxMeth.call(val) }
		makeFromXxxCtor := ReflectUtils.findCtor(toType, makefromName, [fromType])
		if (makeFromXxxCtor != null)
			return |Obj val -> Obj| { makeFromXxxCtor.call(val) }
		
		return null
	}
}
