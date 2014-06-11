
** Methods for finding fields, methods and ctors that match given parameter types.
@Js
class ReflectUtils {

	** Finds a field.
	static Field? findField(Type type, Str fieldName, Type fieldType, Bool? isStatic := null) {
		// 'fields()' returns inherited slots, 'field(name)' does not
		return type.fields.find |field| {
			if (field.name != fieldName) 
				return false
			if (isStatic != null && field.isStatic != isStatic) 
				return false
			return fits(field.type, fieldType)
		}
	}
	
	** Finds a named ctor with the given parameter types.
	static Method? findCtor(Type type, Str ctorName, Type[] params := Type#.emptyList) {
		// 'methods()' returns inherited slots, 'method(name)' does not
		return type.methods.find |method| {
			if (!method.isCtor) 
				return false
			if (method.name != ctorName) 
				return false
			return (paramTypesFitMethodSignature(params, method))
		}
	}

	** Finds a named method with the given parameter types.
	static Method? findMethod(Type type, Str name, Type[] params := Type#.emptyList, Bool? isStatic := null, Type? returnType := null) {
		// 'methods()' returns inherited slots, 'method(name)' does not
		return type.methods.find |method| {
			if (method.isCtor) 
				return false
			if (method.name != name) 
				return false
			if (isStatic != null && method.isStatic != isStatic) 
				return false
			if (returnType != null && !fits(method.returns, returnType))
				return false
			return (paramTypesFitMethodSignature(params, method))
		}
	}

	** Returns 'true' if the given parameter types fit the method signature.
	static Bool paramTypesFitMethodSignature(Type?[] params, Method? method) {
		return method.params.all |methodParam, i->Bool| {
			if (i >= params.size)
				return methodParam.hasDefault
			if (params[i] == null)
				return methodParam.type.isNullable
			return fits(params[i], methodParam.type)
		}
	}
		
	** A replacement for 'Type.fits()' that takes into account type inference for Lists and Maps, and fixes Famtom bugs.
	** Returns 'true' if 'typeA' *fits into* 'typeB'.
	** 
	** Standard usage:
	**   Str#.fits(Obj#)                // --> true
	**   ReflectUtils.fits(Str#, Obj#)  // --> true
	** 
	** List (and Map) type checking:
	**   Int[]#.fits(Obj[]#)                // --> true
	**   ReflectUtils.fits(Int[]#, Obj[]#)  // --> true
	** 
	** List (and Map) type inference. Items in 'Obj[]' *may* fit into 'Int[]'. 
	**   Obj[]#.fits(Int[]#)                // --> false
	**   ReflectUtils.fits(Obj[]#, Int[]#)  // --> true
	** 
	** This is particularly important when calling methods, for many Lists and Maps are defined by the shortcuts '[,]' and 
	** '[:]' which create 'Obj?[]' and 'Obj:Obj?' respectively. 
	** 
	** But List (and Map) types than can *never* fit still return 'false':    
	**   Str[]#.fits(Int[]#)                // --> false
	**   ReflectUtils.fits(Str[]#, Int[]#)  // --> false
	** 
	** Fantom (nullable) bug fix for Lists (and Maps):
	**   Int[]#.fits(Int[]?#)                // --> false
	**   ReflectUtils.fits(Int[]#, Int[]?#)  // --> true
	** 
	** See [List Types and Nullability]`http://fantom.org/sidewalk/topic/2256` for bug details.
	static Bool fits(Type? typeA, Type? typeB) {
		if (typeA == typeB)					return true
		if (typeA == null || typeB == null)	return false
		
		if (typeA.name == "List" && typeB.name == "List")
			return paramFits(typeA, typeB, "V")
			
		if (typeA.name == "Map" && typeB.name == "Map")
			return paramFits(typeA, typeB, "K") && paramFits(typeA, typeB, "V")
			
		return typeA.fits(typeB)
	}

	private static Bool paramFits(Type? typeA, Type? typeB, Str key) {
		paramTypeA := typeA.params[key] ?: Obj?#
		paramTypeB := typeB.params[key] ?: Obj?#
		return (paramTypeA.fits(paramTypeB) || paramTypeB.fits(paramTypeA))
	}
}
