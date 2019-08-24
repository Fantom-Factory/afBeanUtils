
@Js
internal class TestBeanFactory : Test {
	
	Void testBasic() {
		obj := BeanFactory(T_NoCtor#).create
		verify(obj is T_NoCtor)		
	}

	Void testCtorArgsNamed() {
		obj := (T_Ctors?) null
		
		obj = BeanFactory(T_Ctors#).create
		verifyEq(obj.ctor, "make1")

		obj = BeanFactory(T_Ctors#).setByName("value", "m1").create(T_Ctors#make1)
		verifyEq(obj.ctor, "make1")
		verifyEq(obj.value, "m1")

		obj = BeanFactory(T_Ctors#).set(T_Ctors#value, "m2").add(1).create(T_Ctors#make2)
		verifyEq(obj.ctor, "make2")
		verifyEq(obj.value, "m2")
		
		obj = BeanFactory(T_Ctors#).set(T_Ctors#value, "m3").add(1).add(2).create(T_Ctors#make3)
		verifyEq(obj.ctor, "make3")
		verifyEq(obj.value, "m3")

		obj = BeanFactory(T_Ctors#).set(T_Ctors#value, "m4").add(1).add("2").create(T_Ctors#make4)
		verifyEq(obj.ctor, "make4")
		verifyEq(obj.value, "m4")

		obj = BeanFactory(T_Ctors#).set(T_Ctors#value, "m5").add(1).add("2").add(3).create(T_Ctors#make5)
		verifyEq(obj.ctor, "make5")
		verifyEq(obj.value, "m5")

		verifyErrMsg(Err#, "Arguments do not match ctor params for afBeanUtils::T_Ctors.make2(Int i1) - [2]") {
			BeanFactory(T_Ctors#).add(`2`).create(T_Ctors#make2)
		}

		verifyErrMsg(Err#, "Arguments do not match ctor params for afBeanUtils::T_Ctors.make2(Int i1) - [1, 1]") {
			BeanFactory(T_Ctors#).add(1).add(1).create(T_Ctors#make2)
		}
		
		// do again but with an it-block ctor parameter
		
		obj2 := (T_CtorsWithItBlocks?) null
		
		obj2 = BeanFactory(T_CtorsWithItBlocks#).setByName("value", "m1").create(T_CtorsWithItBlocks#make1)
		verifyEq(obj2.ctor, "make1")
		verifyEq(obj2.value, "m1")

		obj2 = BeanFactory(T_CtorsWithItBlocks#).setByName("value", "m2").add(1).create(T_CtorsWithItBlocks#make2)
		verifyEq(obj2.ctor, "make2")
		verifyEq(obj2.value, "m2")
		
		obj2 = BeanFactory(T_CtorsWithItBlocks#).setByName("value", "m3").add(1).add(2).create(T_CtorsWithItBlocks#make3)
		verifyEq(obj2.ctor, "make3")
		verifyEq(obj2.value, "m3")

		obj2 = BeanFactory(T_CtorsWithItBlocks#).setByName("value", "m4").add(1).add("2").create(T_CtorsWithItBlocks#make4)
		verifyEq(obj2.ctor, "make4")
		verifyEq(obj2.value, "m4")

		obj2 = BeanFactory(T_CtorsWithItBlocks#).setByName("value", "m5").add(1).add("2").add(3).create(T_CtorsWithItBlocks#make5)
		verifyEq(obj2.ctor, "make5")
		verifyEq(obj2.value, "m5")
	}
	
	Void testCtorArgs() {
		obj := (T_Ctors?) null
		
		obj = BeanFactory(T_Ctors#).set(T_Ctors#value, "m1").create
		verifyEq(obj.ctor, "make1")
		verifyEq(obj.value, "m1")

		obj = BeanFactory(T_Ctors#).set(T_Ctors#value, "m2").add(1).create
		verifyEq(obj.ctor, "make2")
		verifyEq(obj.value, "m2")
		
		obj = BeanFactory(T_Ctors#).set(T_Ctors#value, "m3").add(1).add(2).create
		verifyEq(obj.ctor, "make3")
		verifyEq(obj.value, "m3")

		verifyErrMsg(Err#, "Found more than 1 ctor on afBeanUtils::T_Ctors [make4, make5] that match argument types - [Int, Str]") {
			BeanFactory(T_Ctors#).add(1).add("2").create
		}

		obj = BeanFactory(T_Ctors#).set(T_Ctors#value, "m5").add(1).add("2").add(3).create
		verifyEq(obj.ctor, "make5")
		verifyEq(obj.value, "m5")

		verifyErrMsg(Err#, "Could not find a ctor on afBeanUtils::T_Ctors to match argument types - [Uri]") {
			BeanFactory(T_Ctors#).add(`2`).create
		}

		// do again but with an optional it-block ctor parameter
		
		obj2 := (T_CtorsWithItBlocks?) null
		
		obj2 = BeanFactory(T_CtorsWithItBlocks#).setByName("value", "m1").create
		verifyEq(obj2.ctor, "make1")
		verifyEq(obj2.value, "m1")

		obj2 = BeanFactory(T_CtorsWithItBlocks#).setByName("value", "m2").add(1).create
		verifyEq(obj2.ctor, "make2")
		verifyEq(obj2.value, "m2")
		
		obj2 = BeanFactory(T_CtorsWithItBlocks#).setByName("value", "m3").add(1).add(2).create
		verifyEq(obj2.ctor, "make3")
		verifyEq(obj2.value, "m3")

		obj2 = BeanFactory(T_CtorsWithItBlocks#).setByName("value", "m4").add(1).add("2").create
		verifyEq(obj2.ctor, "make4")
		verifyEq(obj2.value, "m4")

		obj2 = BeanFactory(T_CtorsWithItBlocks#).setByName("value", "m5").add(1).add("2").add(3).create
		verifyEq(obj2.ctor, "make5")
		verifyEq(obj2.value, "m5")

		// do again but with an mandatory it-block ctor parameter
		
		obj3 := (T_CtorsWithMandatoryItBlocks?) null
		
		obj3 = BeanFactory(T_CtorsWithMandatoryItBlocks#).setByName("value", "m1").create
		verifyEq(obj3.ctor, "make1")
		verifyEq(obj3.value, "m1")

		obj3 = BeanFactory(T_CtorsWithMandatoryItBlocks#).setByName("value", "m2").add(1).create
		verifyEq(obj3.ctor, "make2")
		verifyEq(obj3.value, "m2")
		
		obj3 = BeanFactory(T_CtorsWithMandatoryItBlocks#).setByName("value", "m3").add(1).add(2).create
		verifyEq(obj3.ctor, "make3")
		verifyEq(obj3.value, "m3")

		obj3 = BeanFactory(T_CtorsWithMandatoryItBlocks#).setByName("value", "m4").add(1).add("2").create
		verifyEq(obj3.ctor, "make4")
		verifyEq(obj3.value, "m4")

		obj3 = BeanFactory(T_CtorsWithMandatoryItBlocks#).setByName("value", "m5").add(1).add("2").add(3).create
		verifyEq(obj3.ctor, "make5")
		verifyEq(obj3.value, "m5")
	}
	
	Void testLists() {
		verifyEq(BeanFactory(Obj []#).create.typeof, Obj []#)
		verifyEq(BeanFactory(Int []#).create.typeof, Int []#)
		verifyEq(BeanFactory(Int?[]#).create.typeof, Int?[]#)
		verifyEq(BeanFactory(List  #).create.typeof, Obj?[]#)
	}

	Void testMaps() {
		verifyEq(BeanFactory(Obj:Obj?#).create.typeof, Obj:Obj?#)
		verifyEq(BeanFactory(Int:Obj?#).create.typeof, Int:Obj?#)
		verifyEq(BeanFactory(Int:Obj #).create.typeof, Int:Obj #)
		verifyEq(BeanFactory(Int:Str #).create.typeof, Int:Str #)
		verifyEq(BeanFactory(Map     #).create.typeof, Obj:Obj?#)
	}
	
	Void testDefaultValue() {
		verifyEq(BeanFactory.defaultValue(Int?#), null)
		verifyEq(BeanFactory.defaultValue([Int:Str]?#), null)
		verifyEq(BeanFactory.defaultValue([Int:Str]#).typeof, Int:Str#)
		verifyEq(BeanFactory.defaultValue([Int:Str]#).isImmutable, false)
		verifyEq(BeanFactory.defaultValue(Int[]?#), null)
		verifyEq(BeanFactory.defaultValue(Int[]#).typeof, Int[]#)
		verifyEq(BeanFactory.defaultValue(Int[]#).isImmutable, false)
		verifyEq((BeanFactory.defaultValue(Int[]#) as List).capacity, 0)
		verifyEq(BeanFactory.defaultValue(T_Obj02#)->dude, "ctor")
		verifyEq(BeanFactory.defaultValue(T_Obj03#)->dude, "defVal")
		verifyEq(BeanFactory.defaultValue(Str#), Str.defVal)
		
		verifyErrMsg(ArgErr#, "Env is null and does not have a default value") {
			BeanFactory.defaultValue(Env#)
		}
	}
	
	Void testMisc() {
		verifyErrMsg(ArgErr#, "Ctor afBeanUtils::T_Obj03.make2 does not belong to Str") {
			BeanFactory(Str#).create(T_Obj03#make2)
		}		
	}
	
	Void testSet() {
		verifyErrMsg(ArgErr#, "Field afBeanUtils::T_B.b does not belong to afBeanUtils::T_A") {
			BeanFactory(T_A#).set(T_B#b, 3)
		}

		obj := (T_B) BeanFactory(T_B#).set(T_A#a, 6).set(T_B#b, 9).create
		verifyEq(obj.a, 6)
		verifyEq(obj.b, 9)

		obj = (T_B) BeanFactory(T_B#).setByName("a", 6).setByName("b", 9).create
		verifyEq(obj.a, 6)
		verifyEq(obj.b, 9)
	}
	
	Void testImmutableFieldVals() {
		// fixme - actually, just use BeanBuilder instead!
		obj := (T_Obj05) BeanFactory(T_Obj05#, null, [T_Obj05#ints:[2]]).create
		verifyEq(obj.ints, [2])		
	}
}

//@Js
//internal const class T_Obj05 {
//	const Int[] ints
//	new make(|This| f) { f(this) }
//}
//
//@Js
//internal const class T_Obj02 {
//	const Str? dude
//	static const T_Obj02 defVal := T_Obj02("defVal")
//	new make2() { dude = "ctor" }
//	new make(Str s) { dude = s }
//}
//
//@Js
//internal const class T_Obj03 {
//	const Str? dude
//	static const T_Obj03 defVal := T_Obj03("defVal")
//	new make2(Str s) { dude = s }
//}
//
//@Js
//internal class T_Ctors {
//	Str? value
//	Str  ctor
//	
//	new make1() 							{ ctor = "make1" }
//	new make2(Int i1) 						{ ctor = "make2" }
//	new make3(Int i1, Int i2) 				{ ctor = "make3" }
//	new make4(Int i1, Str s2) 				{ ctor = "make4" }
//	new make5(Int i1, Str s2, Int i3 := 2)	{ ctor = "make5" }
//}
//
//@Js
//internal class T_NoCtor { }

@Js
internal class T_A {
	Int a
}
@Js
internal class T_B : T_A {
	Int b
}

//@Js
//internal const class T_CtorsWithItBlocks {
//	const Str? value
//	const Str  ctor
//	
//	new make1(|This|? f)										{ ctor = "make1"; f?.call(this) }
//	new make2(Int i1, |This|? f := null)	 					{ ctor = "make2"; f?.call(this) }
//	new make3(Int i1, Int i2, |This|? f := null)				{ ctor = "make3"; f?.call(this) }
//	new make4(Int i1, Str s2, |This|? f := null)				{ ctor = "make4"; f?.call(this) }
//	new make5(Int i1, Str s2, Int i3 := 2, |This|? f := null)	{ ctor = "make5"; f?.call(this) }
//}
//
//@Js
//internal const class T_CtorsWithMandatoryItBlocks {
//	const Str? value
//	const Str  ctor
//	
//	new make1(|This| f)							{ ctor = "make1"; f(this) }
//	new make2(Int i1, |This| f)	 				{ ctor = "make2"; f(this) }
//	new make3(Int i1, Int i2, |This| f)			{ ctor = "make3"; f(this) }
//	private new make4(Int i1, Str s2, |This| f)	{ ctor = "make4"; f(this) }
//	new make5(Int i1, Str s2, Int i3, |This| f)	{ ctor = "make5"; f(this) }
//}
