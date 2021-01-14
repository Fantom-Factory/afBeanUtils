
** Static methods for finding fields, methods and ctors that match given parameter types.
@Js
class ReflectUtils {

	** Finds a named field.
	** 
	** Returns 'null' if not found.
	static Field? findField(Type type, Str fieldName, Type? fieldType := null, Bool? isStatic := null) {
		field := type.slot(fieldName, false)
		return _findField(field, fieldType, isStatic)
	}
	
	** Finds a named ctor with the given parameter types.
	** 
	** Returns 'null' if not found.
	static Method? findCtor(Type type, Str ctorName, Type?[]? params := null) {
		ctor := type.slot(ctorName, false)
		return _findCtor(ctor, params ?: Type#.emptyList, false)
	}

	** Finds a named method with the given parameter types.
	** 
	** Returns 'null' if not found.
	static Method? findMethod(Type type, Str methodName, Type?[]? params := null, Bool? isStatic := null, Type? returnType := null) {
		method := type.slot(methodName, false)
		return _findMethod(method, params ?: Type#.emptyList, isStatic, returnType, false)
	}

	** Find fields.

	static Field[] findFields(Type type, Type fieldType, Bool? isStatic := null) {
		type.fields.findAll  { _findField(it, fieldType, isStatic) != null }
	}
	
	** Find ctors with the given parameter types.
	static Method[] findCtors(Type type, Type?[]? params := null, Bool matchArity := false) {
		type.methods.findAll { _findCtor(it, params ?: Type#.emptyList, matchArity) != null }
	}

	** Find methods with the given parameter types.
	static Method[] findMethods(Type type, Type?[]? params := null, Bool? isStatic := null, Type? returnType := null, Bool matchArity := false) {
		type.methods.findAll { _findMethod(it, params ?: Type#.emptyList, isStatic, returnType, matchArity) != null }
	}

	@NoDoc @Deprecated { msg="Use argTypesFitMethod() instead"}
	static Bool paramTypesFitMethodSignature(Type?[] params, Method method) {
		argTypesFitMethod(params, method)
	}
	
	** Returns 'true' if the given parameter types fit the method signature.
	** 
	** This has the same leniency as if you were calling the method function - 
	** so will return 'true' even if there are more 'argTypes' than method parameters.
	** 
	** Set 'matchArity' to 'true' for a stricter match, more appropriate for methods.
	static Bool argTypesFitMethod(Type?[] argTypes, Method method, Bool matchArity := false) {
		// interesting, 'method.params' are not the same as 'method.func.params'
		_argTypesFitParams(argTypes, method.params, matchArity)
	}

	** Returns 'true' if the given parameter types fit the given func.
	static Bool argTypesFitFunc(Type?[] argTypes, Func func) {
		_argTypesFitParams(argTypes, func.params, false)
	}
		
	** A replacement for 'Type.fits()' that takes into account type inference for Lists and Maps, and fixes Famtom bugs.
	** Returns 'true' if 'typeA' *fits into* 'typeB'.
	** 
	** Standard usage:
	**   Str#.fits(Obj#)        // --> true
	**   fits(Str#, Obj#)       // --> true
	** 
	** List (and Map) type checking:
	**   Int[]#.fits(Obj[]#)    // --> true
	**   fits(Int[]#, Obj[]#)   // --> true
	** 
	** List (and Map) type inference. Items in 'Obj[]' *may* fit into 'Int[]'. 
	**   Obj[]#.fits(Int[]#)    // --> false
	**   fits(Obj[]#, Int[]#)   // --> true
	** 
	** This is particularly important when calling methods, for many Lists and Maps are defined by the shortcuts '[,]' and 
	** '[:]' which create 'Obj?[]' and 'Obj:Obj?' respectively. 
	** 
	** But List (and Map) types than can *never* fit still return 'false':    
	**   Str[]#.fits(Int[]#)    // --> false
	**   fits(Str[]#, Int[]#)   // --> false
	** 
	** Fantom (nullable) bug fix for Lists (and Maps):
	**   Int[]#.fits(Int[]?#)   // --> false
	**   fits(Int[]#, Int[]?#)  // --> true
	** 
	** See [List Types and Nullability]`http://fantom.org/sidewalk/topic/2256` for bug details.
	static Bool fits(Type? typeA, Type? typeB) {
		if (typeA == typeB)					return true
		if (typeA == null || typeB == null)	return false
		
		if (typeA.name == "List" && typeB.name == "List")
			return paramFits(typeA, typeB, "V")
			
		if (typeA.name == "Map" && typeB.name == "Map")
			return paramFits(typeA, typeB, "K") && paramFits(typeA, typeB, "V")
		
		// do type inference on funcs
		if (typeA.name == "Func" && typeB.name == "Func") {
			// exclude the return type because Void# doesn't fit Obj#
			return typeA.params.keys.union(typeB.params.keys).exclude { it == "R" }.all {
				paramFits(typeA, typeB, it)
			}
		}
			
		return typeA.fits(typeB)
	}

	private static Bool paramFits(Type? typeA, Type? typeB, Str key) {
		paramTypeA := typeA?.params?.get(key) ?: Obj?#
		paramTypeB := typeB?.params?.get(key) ?: Obj?#
		return fits(paramTypeA, paramTypeB) || fits(paramTypeB, paramTypeA)
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

	private static Method? _findCtor(Slot? ctor, Type?[] params, Bool matchArity) {
		if (ctor == null)
			return null
		if (!ctor.isMethod) 
			return null
		if (!ctor.isCtor) 
			return null
		return _argTypesFitParams(params, ((Method) ctor).params, matchArity) ? ctor: null
	}
	
	private static Method? _findMethod(Slot? method, Type?[] params, Bool? isStatic, Type? returnType, Bool matchArity) {
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
		return _argTypesFitParams(params, ((Method) method).params, matchArity) ? method : null
	}
	
	private static Bool _argTypesFitParams(Type?[] argTypes, Param[] params, Bool matchArity) {
		if (matchArity && argTypes.size > params.size) return false
		return params.all |param, i->Bool| {
			if (i >= argTypes.size)
				return param.hasDefault
			if (argTypes[i] == null)
				return param.type.isNullable
			return fits(argTypes[i], param.type)
		}		
	}
}
