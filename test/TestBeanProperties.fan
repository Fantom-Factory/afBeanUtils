
internal class TestBeanProperties : BeanTest {
	
	Void testDocs() {
		string := "100 101 102"
		result := BeanProperties.call(string, "split[1].get(2).plus(2).toChar")
		verifyEq(result, "3")
		
		buf := Buf()
		BeanProperties.get(buf, "capacity")
		BeanProperties.set(buf, "capacity", 42)
		
		BeanProperties.set(buf, "charset", "UTF-16")
		
		BeanProperties.call(buf, "flush")
		BeanProperties.call(buf, "flush()")
		
		BeanProperties.call(buf, "fill(255, 4)")
		a := BeanProperties.call(buf, "getRange(1..2)")
		verifyEq(0xffff, a->readU2)
		
		buf = Buf()
		BeanProperties.call(buf, "fill", [1, 4])
		a = BeanProperties.call(buf, "getRange()", [1..2])
		verifyEq(0x0101, a->readU2)
		
		buf = Buf()
		BeanProperties.call(buf, "fill(255, 4)", [128, 2])
		verifyEq(0x8080, buf.flip.readU2)
		
		list := Str?["a", "b", "c"]
		verifyEq(BeanProperties.get(list, "[1]"), "b")
		
		list = Str?[,]
		BeanProperties.set(list, "[1]", "b")
		verifyEq(list.size, 2)
		verifyEq(list[0], null)
		verifyEq(list[1], "b")

		list = Str[,]
		BeanProperties.set(list, "[1]", "b")
		verifyEq(list.size, 2)
		verifyEq(list[0], "")
		verifyEq(list[1], "b")

		map := Str:Str[:]
		BeanProperties.set(map, "[1]", "b")
		s := BeanProperties.get(map, "[1]")
		verifyEq(s, "b")
	}

	Void testCreateBasic() {
		
		obj := (T_Obj04?) BeanProperties.create(T_Obj04#, [
			// simple
			"str"			: "wot",
			"int"			: 42,
			
			// fields
			"obj.str"		: "dog",
			"obj.obj.str"	: "cat",
			
			// index leaves
			"nums[0]"		: 1,
			"nums[2]"		: 12,
			"obj.nums[2]"	: 13,
	
			// index branches
			"map[1].str"	: "m1",
			"map[2].str"	: "m2",
			"map[2].int"	: 15,
			
			// methods -> can not, 'cos you need an instance (well, you could retro call it...?)
			"meth.str"		: "dog2",
			"meth.meth.str"	: "cat2",
		])
		
		verify  (obj is T_Obj04)
		verifyEq(obj.str,				"wot")
		verifyEq(obj.int,				42)
		
		verifyEq(obj.obj.str,			"dog")
		verifyEq(obj.obj.obj.str,		"cat")
		
		verifyEq(obj.nums[0],			1)
		verifyEq(obj.nums[2],			12)
		verifyEq(obj.obj.nums[2],		13)

		verifyEq(obj.map[1].str,		"m1")
		verifyEq(obj.map[2].str,		"m2")
		verifyEq(obj.map[2].int,		15)
		
		verifyEq(obj.meth.str,			"dog2")
		verifyEq(obj.meth.meth.str,		"cat2")
	}
}

internal class T_Obj04 {
	Str? 			str
	Int? 			int
	Int[]?			nums
	[Int:T_Obj04]?	map
	T_Obj04?		obj

	T_Obj04?		_meth
	T_Obj04			meth() { if (_meth == null) _meth = T_Obj04(); return _meth }
	
}
