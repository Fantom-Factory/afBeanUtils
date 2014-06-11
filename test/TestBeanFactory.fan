
internal class TestBeanFactory : BeanTest {
	
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
