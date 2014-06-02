
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
}
