
// mimic TestBeanProperty, but for testing creation
internal class TestBeanCreation : Test {
	
	Int? 			basic
	Int[]?			list
	Int?[]?			listNull
	[Str:Str]?		map1
	[Int:Int]?		map2
	T_Obj01?		obj
	Str				judge() { "Dredd" }
	Str				add(Int x, Int y, Int a := -1) { "$x + $y = $a" }

	[Str:T_Obj01]?	map3
	@Operator	T_Obj01? get(Str key) { if (map3 == null) map3 = [:]; return map3[key] }
	@Operator	Void set(Str key, T_Obj01 val) { map3[key] = val }

	TestBeanCreation create(Str:Obj? props) {
		BeanProperties.create(TestBeanCreation#, props)
	}
	
	Void testBasic() {
		obj := create(["basic":42])
		verifyEq(obj.basic, 42)
	}

	Void testList() {
		obj := create(["list[0]":42])
		verifyEq(obj.list[0], 42)
	}

	Void testMap() {
		obj := create(["map1[wot]":"ever", "map2[6]":"9"])
		verifyEq(obj.map1["wot"], "ever")
		verifyEq(obj.map2[6], 9)
	}
	
	Void testObjCreation() {
		obj := create(["obj.str":"hello"])
		verifyEq(obj.obj.str, "hello")
	}
	
	Void testSetMethod() {
		verifyErrMsg(BeanCreateErr#, "Could not instantiate afBeanUtils::TestBeanCreation") {
			obj := create(["judge":"hello"])
		}
	}

	Void testListIndexCreation() {
		obj := create(["list[3]":42])
		verifyEq(obj.list[0], Int.defVal)
		verifyEq(obj.list[1], Int.defVal)
		verifyEq(obj.list[2], Int.defVal)
		verifyEq(obj.list[3], 42)
		verifyEq(obj.list.size, 4)
	}

	Void testListIndexNullCreation() {
		obj := create(["listNull[2]":42])
		verifyEq(obj.listNull[0], null)
		verifyEq(obj.listNull[1], null)
		verifyEq(obj.listNull[2], 42)
		verifyEq(obj.listNull.size, 3)
	}
	
	Void testNested() {
		obj := create(["obj.list[1].map[wot].str":"boobies"])
		verifyEq(obj.obj.list[1].map["wot"].str, "boobies")
	}

	Void testGetSetOperators() {
		obj := create(["obj[2].str":"boobies"])
		verifyEq(obj.obj[2].str, "boobies")
	}

	Void testMethodNested() {
		obj := create(["obj.list[2].map[wot].meth(dredd)[2].str":"dreddy"])
		verifyEq(obj.obj.list[2].map["wot"].meth("wotever")[2].str, "dreddy")
	}
}

