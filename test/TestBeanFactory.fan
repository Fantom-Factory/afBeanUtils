
internal class TestBeanFactory : BeanTest {
	
	Void testBasic() {
		obj := BeanFactory(T_NoCtor#).create
		verify(obj is T_NoCtor)		
	}

	Void testCtorArgsNamed() {
		obj := (T_Ctors?) null
		
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

		verifyErrMsg(Err#, ErrMsgs.factory_ctorArgMismatch(T_Ctors#make2, [`2`])) {
			BeanFactory(T_Ctors#).add(`2`).create(T_Ctors#make2)
		}

		verifyErrMsg(Err#, ErrMsgs.factory_ctorArgMismatch(T_Ctors#make2, [1, 1])) {
			BeanFactory(T_Ctors#).add(1).add(1).create(T_Ctors#make2)
		}
		
		// do again but with a default ctor parameter
		
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
		
		obj = BeanFactory(T_Ctors#).create
		verifyEq(obj.ctor, "make1")

		obj = BeanFactory(T_Ctors#).add(1).create
		verifyEq(obj.ctor, "make2")
		
		obj = BeanFactory(T_Ctors#).add(1).add(2).create
		verifyEq(obj.ctor, "make3")

		verifyErrMsg(Err#, ErrMsgs.factory_tooManyCtorsFound(T_Ctors#, "make4 make5".split, [Int#, Str#])) {
			BeanFactory(T_Ctors#).add(1).add("2").create
		}

		obj = BeanFactory(T_Ctors#).add(1).add("2").add(3).create
		verifyEq(obj.ctor, "make5")

		verifyErrMsg(Err#, ErrMsgs.factory_noCtorsFound(T_Ctors#, [Uri#])) {
			BeanFactory(T_Ctors#).add(`2`).create
		}
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
		
		verifyErrMsg(Err#, ErrMsgs.factory_defValNotFound(Env#)) {
			BeanFactory.defaultValue(Env#)
		}
	}
	
	Void testMisc() {
		verifyErrMsg(Err#, ErrMsgs.factory_ctorWrongType(Str#, T_Obj03#make2)) {
			BeanFactory(Str#).create(T_Obj03#make2)
		}		
	}
	
	Void testNamedCtorWithItBlock() {
//		if it-block, set fields via it-block
//		if no it-block, set fields post ctor
		
		d:= T_CtorsWithItBlocks#make1.params[-1].type.fits(|This|#)
		echo(d)

		d= Field.makeSetFunc([T_CtorsWithItBlocks#value: "2"]).typeof.fits(T_CtorsWithItBlocks#make1.params[-1].type)
		echo(d)
		
		d = ReflectUtils.argTypesFitMethod([Field.makeSetFunc([T_CtorsWithItBlocks#value: "2"]).typeof], T_CtorsWithItBlocks#make1)
		echo(d)		
	}
	
	Void testSet() {
		verifyErrMsg(ArgErr#, ErrMsgs.factory_fieldWrongParent(T_A#, T_B#b)) {
			BeanFactory(T_A#).set(T_B#b, 3)
		}

		obj := (T_B) BeanFactory(T_B#).set(T_A#a, 6).set(T_B#b, 9).create
		verifyEq(obj.a, 6)
		verifyEq(obj.b, 9)

		obj = (T_B) BeanFactory(T_B#).setByName("a", 6).setByName("b", 9).create
		verifyEq(obj.a, 6)
		verifyEq(obj.b, 9)
	}
}

const class T_Obj02 {
	const Str? dude
	static const T_Obj02 defVal := T_Obj02("defVal")
	new make2() { dude = "ctor" }
	new make(Str s) { dude = s }
}

const class T_Obj03 {
	const Str? dude
	static const T_Obj03 defVal := T_Obj03("defVal")
	new make2(Str s) { dude = s }
}

class T_Ctors {
	Str? value
	Str  ctor
	
	new make1() 							{ ctor = "make1" }
	new make2(Int i1) 						{ ctor = "make2" }
	new make3(Int i1, Int i2) 				{ ctor = "make3" }
	new make4(Int i1, Str s2) 				{ ctor = "make4" }
	new make5(Int i1, Str s2, Int i3 := 2)	{ ctor = "make5" }
}

class T_NoCtor { }

class T_A {
	Int a
}
class T_B : T_A {
	Int b
}

const class T_CtorsWithItBlocks {
	const Str? value
	const Str  ctor
	
	new make1(|This|? f := null)								{ ctor = "make1"; f?.call(this); echo("MAKEING M1 $f $value") }
	new make2(Int i1, |This|? f := null)	 					{ ctor = "make2"; f?.call(this) }
	new make3(Int i1, Int i2, |This|? f := null)				{ ctor = "make3"; f?.call(this) }
	new make4(Int i1, Str s2, |This|? f := null)				{ ctor = "make4"; f?.call(this) }
	new make5(Int i1, Str s2, Int i3 := 2, |This|? f := null)	{ ctor = "make5"; f?.call(this) }
}
