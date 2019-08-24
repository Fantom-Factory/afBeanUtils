
@Js
internal class TestBeanBuilder : Test {
	
	Void testDude() {
		ints := [1]
		ints = List.makeObj(ints.size)
	}
	
	Void testBasic() {
		obj := build(T_NoCtor#)
		verify(obj is T_NoCtor)
	}

	Void testCtor() {
		obj := (T_Ctors?) null
		
		obj = build(T_Ctors#)
		verifyEq(obj.ctor, "make1")

		obj = build(T_Ctors#, [T_Ctors#value:"m2"], [1])
		verifyEq(obj.ctor, "make2")
		verifyEq(obj.value, "m2")
		
		obj = build(T_Ctors#, [T_Ctors#value:"m3"], [1, 2])
		verifyEq(obj.ctor, "make3")
		verifyEq(obj.value, "m3")

		verifyErrMsg(Err#, "Found more than 1 ctor on afBeanUtils::T_Ctors [make4, make5] that match argument types - [Int, Str]") {
			build(T_Ctors#, [T_Ctors#value:"m4"], [1, "2"])
		}

		obj = build(T_Ctors#, [T_Ctors#value:"m5"], [1, "2", 3])
		verifyEq(obj.ctor, "make5")
		verifyEq(obj.value, "m5")
		
		// do again but with an it-block ctor parameter
		
		obj2 := (T_CtorsWithItBlocks?) null
		
		obj2 = build(T_CtorsWithItBlocks#, [T_CtorsWithItBlocks#value:"m1"])
		verifyEq(obj2.ctor, "make1")
		verifyEq(obj2.value, "m1")

		obj2 = build(T_CtorsWithItBlocks#, [T_CtorsWithItBlocks#value:"m2"], [1])
		verifyEq(obj2.ctor, "make2")
		verifyEq(obj2.value, "m2")
		
		obj2 = build(T_CtorsWithItBlocks#, [T_CtorsWithItBlocks#value:"m3"], [1, 2])
		verifyEq(obj2.ctor, "make3")
		verifyEq(obj2.value, "m3")

		obj2 = build(T_CtorsWithItBlocks#, [T_CtorsWithItBlocks#value:"m4"], [1, "2"])
		verifyEq(obj2.ctor, "make4")
		verifyEq(obj2.value, "m4")

		obj2 = build(T_CtorsWithItBlocks#, [T_CtorsWithItBlocks#value:"m5"], [1, "2", 3])
		verifyEq(obj2.ctor, "make5")
		verifyEq(obj2.value, "m5")
	}
	
	Void testCtorArgs() {
		obj := (T_Ctors?) null
		
		obj = build(T_Ctors#)
		verifyEq(obj.ctor, "make1")

		obj = build(T_Ctors#, [T_Ctors#value:"m2"], [1])
		verifyEq(obj.ctor, "make2")
		verifyEq(obj.value, "m2")
		
		obj = build(T_Ctors#, [T_Ctors#value:"m3"], [1, 2])
		verifyEq(obj.ctor, "make3")
		verifyEq(obj.value, "m3")

		verifyErrMsg(Err#, "Found more than 1 ctor on afBeanUtils::T_Ctors [make4, make5] that match argument types - [Int, Str]") {
			build(T_Ctors#, [T_Ctors#value:"m4"], [1, "2"])
		}

		obj = build(T_Ctors#, [T_Ctors#value:"m5"], [1, "2", 3])
		verifyEq(obj.ctor, "make5")
		verifyEq(obj.value, "m5")

		verifyErrMsg(Err#, "Could not find a ctor on afBeanUtils::T_Ctors to match argument types - [Uri]") {
			build(T_Ctors#, [T_Ctors#value:"m4"], [`2`])
		}

		// do again but with an optional it-block ctor parameter
		
		obj2 := (T_CtorsWithItBlocks?) null
		
		obj2 = build(T_CtorsWithItBlocks#, [T_CtorsWithItBlocks#value:"m1"])
		verifyEq(obj2.ctor, "make1")
		verifyEq(obj2.value, "m1")

		obj2 = build(T_CtorsWithItBlocks#, [T_CtorsWithItBlocks#value:"m2"], [1])
		verifyEq(obj2.ctor, "make2")
		verifyEq(obj2.value, "m2")
		
		obj2 = build(T_CtorsWithItBlocks#, [T_CtorsWithItBlocks#value:"m3"], [1, 2])
		verifyEq(obj2.ctor, "make3")
		verifyEq(obj2.value, "m3")

		obj2 = build(T_CtorsWithItBlocks#, [T_CtorsWithItBlocks#value:"m4"], [1, "2"])
		verifyEq(obj2.ctor, "make4")
		verifyEq(obj2.value, "m4")

		obj2 = build(T_CtorsWithItBlocks#, [T_CtorsWithItBlocks#value:"m5"], [1, "2", 3])
		verifyEq(obj2.ctor, "make5")
		verifyEq(obj2.value, "m5")

		// do again but with an mandatory it-block ctor parameter
		
		obj3 := (T_CtorsWithMandatoryItBlocks?) null
		
		obj3 = build(T_CtorsWithMandatoryItBlocks#, [T_CtorsWithMandatoryItBlocks#value:"m1"])
		verifyEq(obj3.ctor, "make1")
		verifyEq(obj3.value, "m1")

		obj3 = build(T_CtorsWithMandatoryItBlocks#, [T_CtorsWithMandatoryItBlocks#value:"m2"], [1])
		verifyEq(obj3.ctor, "make2")
		verifyEq(obj3.value, "m2")
		
		obj3 = build(T_CtorsWithMandatoryItBlocks#, [T_CtorsWithMandatoryItBlocks#value:"m3"], [1, 2])
		verifyEq(obj3.ctor, "make3")
		verifyEq(obj3.value, "m3")

		obj3 = build(T_CtorsWithMandatoryItBlocks#, [T_CtorsWithMandatoryItBlocks#value:"m4"], [1, "2"])
		verifyEq(obj3.ctor, "make4")
		verifyEq(obj3.value, "m4")

		obj3 = build(T_CtorsWithMandatoryItBlocks#, [T_CtorsWithMandatoryItBlocks#value:"m5"], [1, "2", 3])
		verifyEq(obj3.ctor, "make5")
		verifyEq(obj3.value, "m5")
	}
	
	Void testLists() {
		verifyEq(build(Obj []#).typeof, Obj []#)
		verifyEq(build(Int []#).typeof, Int []#)
		verifyEq(build(Int?[]#).typeof, Int?[]#)
		verifyEq(build(List  #).typeof, Obj?[]#)
	}

	Void testMaps() {
		verifyEq(build(Obj:Obj?#).typeof, Obj:Obj?#)
		verifyEq(build(Int:Obj?#).typeof, Int:Obj?#)
		verifyEq(build(Int:Obj #).typeof, Int:Obj #)
		verifyEq(build(Int:Str #).typeof, Int:Str #)
		verifyEq(build(Map     #).typeof, Obj:Obj?#)
	}
	
	Void testDefaultValue() {
		verifyEq(BeanBuilder.defVal(Int?#), null)
		verifyEq(BeanBuilder.defVal([Int:Str]?#), null)
		verifyEq(BeanBuilder.defVal([Int:Str]#).typeof, Int:Str#)
		verifyEq(BeanBuilder.defVal([Int:Str]#).isImmutable, false)
		verifyEq(BeanBuilder.defVal(Int[]?#), null)
		verifyEq(BeanBuilder.defVal(Int[]#).typeof, Int[]#)
		verifyEq(BeanBuilder.defVal(Int[]#).isImmutable, false)
		verifyEq((BeanBuilder.defVal(Int[]#) as List).capacity, 0)
		verifyEq(BeanBuilder.defVal(T_Obj02#)->dude, "ctor")
		verifyEq(BeanBuilder.defVal(T_Obj03#)->dude, "defVal")
		verifyEq(BeanBuilder.defVal(Str#), Str.defVal)
		
		verifyErrMsg(ArgErr#, "Could not find a defVal for Env") {
			BeanBuilder.defVal(Env#)
		}
	}
	
	Void testMisc() {
		verifyErrMsg(Err#, "Could not find a ctor on Str to match argument types - [Method]") {
			build(Str#, null, [T_Obj03#make2]) { echo(it) }
		}		
	}
	
	Void testImmutableFieldVals() {
		// FIXME !!!
		obj := (T_Obj05) build(T_Obj05#, [T_Obj05#ints:[2]])
		verifyEq(obj.ints, [2])		
	}
	
	private Obj? build(Type type, [Field:Obj?]? fieldVals := null, Obj?[]? ctorArgs := null) {
		BeanBuilder.build(type, fieldVals, ctorArgs)
	}
}

@Js
internal const class T_Obj05 {
	const Int[] ints
	new make(|This| f) { f(this) }
}

@Js
internal const class T_Obj02 {
	const Str? dude
	static const T_Obj02 defVal := T_Obj02("defVal")
	new make2() { dude = "ctor" }
	new make(Str s) { dude = s }
}

@Js
internal const class T_Obj03 {
	const Str? dude
	static const T_Obj03 defVal := T_Obj03("defVal")
	new make2(Str s) { dude = s }
}

@Js
internal class T_NoCtor { }

@Js
internal class T_Ctors {
	Str? value
	Str  ctor
	
	new make1() 							{ ctor = "make1" }
	new make2(Int i1) 						{ ctor = "make2" }
	new make3(Int i1, Int i2) 				{ ctor = "make3" }
	new make4(Int i1, Str s2) 				{ ctor = "make4" }
	new make5(Int i1, Str s2, Int i3 := 2)	{ ctor = "make5" }
}

@Js
internal const class T_CtorsWithItBlocks {
	const Str? value
	const Str  ctor
	
	new make1(|This|? f)										{ ctor = "make1"; f?.call(this) }
	new make2(Int i1, |This|? f := null)	 					{ ctor = "make2"; f?.call(this) }
	new make3(Int i1, Int i2, |This|? f := null)				{ ctor = "make3"; f?.call(this) }
	new make4(Int i1, Str s2, |This|? f := null)				{ ctor = "make4"; f?.call(this) }
	new make5(Int i1, Str s2, Int i3 := 2, |This|? f := null)	{ ctor = "make5"; f?.call(this) }
}

@Js
internal const class T_CtorsWithMandatoryItBlocks {
	const Str? value
	const Str  ctor
	
	new make1(|This| f)							{ ctor = "make1"; f(this) }
	new make2(Int i1, |This| f)	 				{ ctor = "make2"; f(this) }
	new make3(Int i1, Int i2, |This| f)			{ ctor = "make3"; f(this) }
	private new make4(Int i1, Str s2, |This| f)	{ ctor = "make4"; f(this) }
	new make5(Int i1, Str s2, Int i3, |This| f)	{ ctor = "make5"; f(this) }
}
