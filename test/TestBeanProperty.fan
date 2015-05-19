
internal class TestBeanProperty : BeanTest {
	
	Int? 			basic
	Int[]?			list
	Int?[]?			listNull
	[Str:Str]?		map1
	[Int:Int]?		map2
	[Str:T_Obj01]?	map3
	T_Obj01?		obj
	Str				judge() { "Dredd" }
	Str				add(Int x, Int y, Int a := -1) { "$x + $y = $a" }
	T_Obj01?		obj2() { obj }

	@Operator
	T_Obj01? get(Str key) { 
		if (map3 == null)
			map3 = [:]
		return map3[key] 
	}

	@Operator
	Void set(Str key, T_Obj01 val) { map3[key] = val }

	Void testBasic() {
		prop := BeanPropertyFactory().parse("basic")
		
		// test normal
		prop.set(this, 69)
		verifyEq(basic, 69)
		verifyEq(prop.get(this), 69)
		
		// test type coercion
		prop.set(this, "42")
		verifyEq(basic, 42)
		verifyEq(prop.get(this), 42)
	}

	Void testList() {
		prop := BeanPropertyFactory().parse("list[0]")
		list = [,]

		// test normal
		prop.set(this, 69)
		verifyEq(list[0], 69)
		verifyEq(prop.get(this), 69)
		
		// test another
		BeanPropertyFactory().parse("list[1]").set(this, 3)
		verifyEq(list[1], 3)
		
		// test type coercion
		prop.set(this, "42")
		verifyEq(list[0], 42)
		verifyEq(prop.get(this), 42)
	}

	Void testMap() {
		prop1 := BeanPropertyFactory().parse("map1[wot]")
		prop2 := BeanPropertyFactory().parse("map2[6]")
		map1 = [:]
		map2 = [:]

		// test normal
		prop1.set(this, "ever")
		verifyEq(map1["wot"], "ever")
		verifyEq(prop1.get(this), "ever")
		
		// test another
		BeanPropertyFactory().parse("map1[tough]").set(this, "man")
		verifyEq(map1["tough"], "man")
		
		// test type coercion
		prop2.set(this, "9")
		verifyEq(map2[6], 9)
		verifyEq(prop2.get(this), 9)
	}
	
	Void testObjCreation() {
		prop := BeanPropertyFactory().parse("obj.str")
		prop.set(this, "hello")
		verifyEq(this.obj.str, "hello")
		verifyEq(prop.get(this), "hello")
	}

	Void testListCreation() {
		prop := BeanPropertyFactory().parse("list[0]")
		prop.set(this, 69)
		verifyEq(list[0], 69)
		verifyEq(prop.get(this), 69)
	}
	
	Void testListIndexCreation() {
		prop := BeanPropertyFactory().parse("list[3]")
		prop.set(this, 69)
		verifyEq(list[3], 69)
		verifyEq(prop.get(this), 69)

		verifyEq(list[0], Int.defVal)
		verifyEq(list[1], Int.defVal)
		verifyEq(list[2], Int.defVal)
		verifyEq(list.size, 4)

		prop = BeanPropertyFactory().parse("list[5]")
		prop.set(this, 42)
		verifyEq(list[4], Int.defVal)
		verifyEq(list[5], 42)
		verifyEq(list.size, 6)

		prop = BeanPropertyFactory() { it.maxListSize = 100 }.parse("list[101]")
		verifyErrMsg(ArgErr#, ErrMsgs.property_crazyList(101, Int#)) {
			prop.set(this, 6)			
		}
	}

	Void testListIndexNullCreation() {
		prop := BeanPropertyFactory().parse("listNull[2]")
		prop.set(this, 69)
		verifyEq(listNull[0], null)
		verifyEq(listNull[1], null)
		verifyEq(listNull[2], 69)
		verifyEq(listNull.size, 3)
	}
	
	Void testMapCreation() {
		prop := BeanPropertyFactory().parse("map1[wot]")
		prop.set(this, "ever")
		verifyEq(map1["wot"], "ever")
		verifyEq(prop.get(this), "ever")
	}

	Void testMapValueCreation() {
		prop := BeanPropertyFactory().parse("map3[wot].str")
		prop.set(this, "ever")
		verifyEq(map3["wot"].str, "ever")
		verifyEq(prop.get(this), "ever")
	}
	
	Void testNested() {
		prop := BeanPropertyFactory().parse("obj.list[1].map[wot].str")
		prop.set(this, "ever")
		verifyEq(obj.list[1].map["wot"].str, "ever")
		verifyEq(prop.get(this), "ever")
	}

	Void testGetSetOperators() {
		prop := BeanPropertyFactory().parse("obj[2].str")
		prop.set(this, "ever")
		verifyEq(obj[2].str, "ever")
		verifyEq(prop.get(this), "ever")

		// test @Op getter following a method 
		prop = BeanPropertyFactory().parse("obj2[2].str")
		prop.set(this, "blah")
		verifyEq(obj2[2].str, "blah")
		verifyEq(prop.get(this), "blah")

		prop = BeanPropertyFactory().parse("[woot].str")
		prop.set(this, "ever")
		verifyEq(get("woot").str, "ever")
		verifyEq(prop.get(this), "ever")
	}
	
	Void testMethod() {
		prop := BeanPropertyFactory().parse("judge")
		verifyEq(prop.get(this), "Dredd")
		verifyErrMsg(ArgErr#, ErrMsgs.property_setOnMethod(#judge)) {
			prop.set(this, "Anderson")
		}

		prop = BeanPropertyFactory().parse("judge()")
		verifyEq(prop.get(this), "Dredd")
		verifyErrMsg(ArgErr#, ErrMsgs.property_setOnMethod(#judge)) {
			prop.set(this, "Dredd")			
		}
	}
	
	Void testMethodArgs() {
		prop := BeanPropertyFactory().parse("add(1, 2, 3)")
		verifyEq(prop.get(this), "1 + 2 = 3")

		prop = BeanPropertyFactory().parse("add(1, 2)")
		verifyEq(prop.get(this), "1 + 2 = -1")
	}

	Void testMethodNested() {
		prop := BeanPropertyFactory().parse("obj.list[2].map[wot].meth(dredd).str")
		verifyEq(prop[this], "dredd")
	}
}

internal class T_Obj01 {
	Str? 			str
	T_Obj01[]?		list
	[Str:T_Obj01]?	map
	[Int:T_Obj01?]	map2 := [:]
	
	T_Obj01?		_meth
	T_Obj01	meth(Str str) { if (_meth == null) _meth = T_Obj01(); _meth.str = str; return _meth }
	
	@Operator
	T_Obj01? get(Int key) {
		return map2[key]
	}

	@Operator
	Void set(Int key, T_Obj01 val) {
		map2[key] = val
	}
}

