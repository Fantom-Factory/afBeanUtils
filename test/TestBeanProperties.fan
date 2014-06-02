
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
	}
	
}
