
** Methods for finding fields, methods and ctors that match given parameter types.
@Js
class ReflectUtils {

	** Finds a named field.
	static Field? findField(Type type, Str fieldName, Type? fieldType := null, Bool? isStatic := null) {
		field := type.slot(fieldName, false)
		return _findField(field, fieldType, isStatic)
	}
	
	** Finds a named ctor with the given parameter types.
	static Method? findCtor(Type type, Str ctorName, Type[] params := Type#.emptyList) {
		ctor := type.slot(ctorName, false)
		return _findCtor(ctor, params)
	}

	** Finds a named method with the given parameter types.
	static Method? findMethod(Type type, Str methodName, Type[] params := Type#.emptyList, Bool? isStatic := null, Type? returnType := null) {
		method := type.slot(methodName, false)
		return _findMethod(method, params, isStatic, returnType)
	}

	** Find fields.
	static Field[] findFields(Type type, Type fieldType, Bool? isStatic := null) {
		type.fields.findAll  { _findField(it, fieldType, isStatic) != null }
	}
	
	** Find ctors with the given parameter types.
	static Method[] findCtors(Type type, Type[] params := Type#.emptyList) {
		type.methods.findAll { _findCtor(it, params) != null }
	}

	** Find methods with the given parameter types.
	static Method[] findMethods(Type type, Type[] params := Type#.emptyList, Bool? isStatic := null, Type? returnType := null) {
		type.methods.findAll { _findMethod(it, params, isStatic, returnType) != null }
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
	
	private static Field? _findField(Slot? field, Type? fieldType, Bool? isStatic) {
		if (field == null)
			return null
		if (!field.isField)
			return null
		if (isStatic != null && field.isStatic != isStatic) 
			return null
		if (fieldType != null && !fits(((Field) field).type, fieldType))
			return null
		return field
	}

	static Method? _findCtor(Slot? ctor, Type[] params) {
		if (ctor == null)
			return null
		if (!ctor.isMethod) 
			return null
		if (!ctor.isCtor) 
			return null
		return paramTypesFitMethodSignature(params, ctor) ? ctor: null
	}
	
	static Method? _findMethod(Slot? method, Type[] params, Bool? isStatic, Type? returnType) {
		if (method == null)
			return null
		if (!method.isMethod) 
			return null
		if (method.isCtor) 
			return null
		if (isStatic != null && method.isStatic != isStatic) 
			return null
		if (returnType != null && !fits(((Method) method).returns, returnType))
			return null
		return paramTypesFitMethodSignature(params, method) ? method : null
	}
}
