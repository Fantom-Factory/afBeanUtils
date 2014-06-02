
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

}
