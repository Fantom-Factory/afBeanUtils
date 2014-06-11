
internal class TestBeanFactory : BeanTest {
	
	Void testCtorArgsNamed() {
		obj := (T_Ctors?) null
		
		obj = BeanFactory(T_Ctors#).create(T_Ctors#make1)
		verifyEq(obj.ctor, "make1")

		obj = BeanFactory(T_Ctors#).add(1).create(T_Ctors#make2)
		verifyEq(obj.ctor, "make2")
		
		obj = BeanFactory(T_Ctors#).add(1).add(2).create(T_Ctors#make3)
		verifyEq(obj.ctor, "make3")

		obj = BeanFactory(T_Ctors#).add(1).add("2").create(T_Ctors#make4)
		verifyEq(obj.ctor, "make4")

		obj = BeanFactory(T_Ctors#).add(1).add("2").add(3).create(T_Ctors#make5)
		verifyEq(obj.ctor, "make5")

		verifyErrMsg(Err#, ErrMsgs.factory_ctorArgMismatch(T_Ctors#make2, [`2`])) {
			BeanFactory(T_Ctors#).add(`2`).create(T_Ctors#make2)
		}

		verifyErrMsg(Err#, ErrMsgs.factory_ctorArgMismatch(T_Ctors#make2, [1, 1])) {
			BeanFactory(T_Ctors#).add(1).add(1).create(T_Ctors#make2)
		}
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
	Str ctor
	
	new make1() 							{ ctor = "make1" }
	new make2(Int i1) 						{ ctor = "make2" }
	new make3(Int i1, Int i2) 				{ ctor = "make3" }
	new make4(Int i1, Str s2) 				{ ctor = "make4" }
	new make5(Int i1, Str s2, Int i3 := 2)	{ ctor = "make5" }
}

