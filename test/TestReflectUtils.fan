
** Paradox :: Just what is 'Void?'?
@Js
internal class TestReflectUtils : BeanTest {

	Void testFindField() {
		field := ReflectUtils.findField(MyReflectTestUtils2#, "int", Int#)
		verifyEq(field, MyReflectTestUtils2#int)
		field = ReflectUtils.findField(MyReflectTestUtils1#, "int", Int#)
		verifyEq(field, MyReflectTestUtils1#int)

		field = ReflectUtils.findField(MyReflectTestUtils2#, "obj", Obj#)
		verifyEq(field, MyReflectTestUtils1#obj)
		field = ReflectUtils.findField(MyReflectTestUtils1#, "obj", Obj#)
		verifyEq(field, MyReflectTestUtils1#obj)

		field = ReflectUtils.findField(MyReflectTestUtils2#, "int", Num#)
		verifyEq(field, MyReflectTestUtils2#int)
		field = ReflectUtils.findField(MyReflectTestUtils1#, "Obj", Float#)
		verifyNull(field)

		field = ReflectUtils.findField(MyReflectTestUtils1#, "wotever", Float#)
		verifyNull(field)
	}

	Void testFindCtor() {
		ctor := ReflectUtils.findCtor(MyReflectTestUtils2#, "makeCtor2")
		verifyEq(ctor, MyReflectTestUtils2#makeCtor2)
		ctor = ReflectUtils.findCtor(MyReflectTestUtils1#, "makeCtor1")
		verifyEq(ctor, MyReflectTestUtils1#makeCtor1)

		// inherited ctors should not be found
		ctor = ReflectUtils.findCtor(MyReflectTestUtils2#, "makeCtor1")
		verifyNull(ctor)
	}

	Void testFindCtors() {
		ctors := ReflectUtils.findCtors(MyReflectTestUtils2#)
		verifyEq(ctors.size, 1)
		verifyEq(ctors.first.parent, MyReflectTestUtils2#)
	}

	Void testFindMethod() {
		method := ReflectUtils.findMethod(MyReflectTestUtils2#, "method1", null, false, Void#)
		verifyEq(method, MyReflectTestUtils2#method1)
		method = ReflectUtils.findMethod(MyReflectTestUtils2#, "method1", null, false, Int#)
		verifyNull(method)
		method = ReflectUtils.findMethod(MyReflectTestUtils2#, "method1", null, false, Int?#)
		verifyNull(method)

		method = ReflectUtils.findMethod(MyReflectTestUtils2#, "method2", null, false, Num#)
		verifyEq(method, MyReflectTestUtils2#method2)
		method = ReflectUtils.findMethod(MyReflectTestUtils2#, "method2", null, false, Num?#)
		verifyEq(method, MyReflectTestUtils2#method2)
		method = ReflectUtils.findMethod(MyReflectTestUtils2#, "method2", null, false, Obj#)
		verifyEq(method, MyReflectTestUtils2#method2)
		method = ReflectUtils.findMethod(MyReflectTestUtils2#, "method2", null, false, Obj?#)
		verifyEq(method, MyReflectTestUtils2#method2)
		method = ReflectUtils.findMethod(MyReflectTestUtils2#, "method2", null, false, Int#)
		verifyNull(method)
		method = ReflectUtils.findMethod(MyReflectTestUtils2#, "method2", null, false, Int?#)
		verifyNull(method)

		// it seems Nullable has no effect on Type#fits()
		// this makes life easier as we don't have to specify the null '?' all the time
		Obj.echo("Num# == Num?#    -> ${Num# == Num?#}")	// Num# == Num?#    -> false
		Obj.echo("Num#.fits(Num?#) -> ${Num#.fits(Num?#)}")	// Num#.fits(Num?#) -> true
		Obj.echo("Num?#.fits(Num#) -> ${Num?#.fits(Num#)}")	// Num?#.fits(Num#) -> true
		
		method = ReflectUtils.findMethod(MyReflectTestUtils2#, "method3", null, false, Num#)
		verifyEq(method, MyReflectTestUtils2#method3)	// 'cos Num# fits Num?#
		method = ReflectUtils.findMethod(MyReflectTestUtils2#, "method3", null, false, Num?#)
		verifyEq(method, MyReflectTestUtils2#method3)
		method = ReflectUtils.findMethod(MyReflectTestUtils2#, "method3", null, false, Obj#)
		verifyEq(method, MyReflectTestUtils2#method3)	// 'cos Num# fits Num?#
		method = ReflectUtils.findMethod(MyReflectTestUtils2#, "method3", null, false, Obj?#)
		verifyEq(method, MyReflectTestUtils2#method3)
		method = ReflectUtils.findMethod(MyReflectTestUtils2#, "method3", null, false, Int#)
		verifyNull(method)
		method = ReflectUtils.findMethod(MyReflectTestUtils2#, "method3", null, false, Int?#)
		verifyNull(method)
	}
	
	Void testParams() {
		// simple case
		verify(ReflectUtils.argTypesFitMethod([,], MyReflectTestUtils2#params1))
		
		// I can pass in more params than required, it's up to the method to say whether it needs 
		// them or not - but if it DOES declare the params then they have to fit
		// Nullable types don't matter as null is mainly a runtime check, to nip it in the bud at source
		verify(ReflectUtils.argTypesFitMethod([Obj#], MyReflectTestUtils2#params1))

		verifyFalse	(ReflectUtils.argTypesFitMethod([,],    		MyReflectTestUtils2#params2))
		verify		(ReflectUtils.argTypesFitMethod([Num#], 		MyReflectTestUtils2#params2))
		verifyFalse	(ReflectUtils.argTypesFitMethod([Obj#], 		MyReflectTestUtils2#params2))
		verify		(ReflectUtils.argTypesFitMethod([Int#], 		MyReflectTestUtils2#params2))
		verify		(ReflectUtils.argTypesFitMethod([Int#, Int#],	MyReflectTestUtils2#params2))

		verifyFalse	(ReflectUtils.argTypesFitMethod([,],    		MyReflectTestUtils2#params3))
		verify		(ReflectUtils.argTypesFitMethod([Num#], 		MyReflectTestUtils2#params3))
		verifyFalse	(ReflectUtils.argTypesFitMethod([Obj#], 		MyReflectTestUtils2#params3))
		verify		(ReflectUtils.argTypesFitMethod([Int#], 		MyReflectTestUtils2#params3))
		verify		(ReflectUtils.argTypesFitMethod([Int#, Int#],	MyReflectTestUtils2#params3))

		verify		(ReflectUtils.argTypesFitMethod([,],    		MyReflectTestUtils2#params4))
		verify		(ReflectUtils.argTypesFitMethod([Num#], 		MyReflectTestUtils2#params4))
		verifyFalse	(ReflectUtils.argTypesFitMethod([Obj#], 		MyReflectTestUtils2#params4))
		verify		(ReflectUtils.argTypesFitMethod([Int#], 		MyReflectTestUtils2#params4))
		verify		(ReflectUtils.argTypesFitMethod([Int#, Int#],	MyReflectTestUtils2#params4))

		verify		(ReflectUtils.argTypesFitMethod([,],    		MyReflectTestUtils2#params5))
		verify		(ReflectUtils.argTypesFitMethod([Num#], 		MyReflectTestUtils2#params5))
		verifyFalse	(ReflectUtils.argTypesFitMethod([Obj#],			MyReflectTestUtils2#params5))
		verify		(ReflectUtils.argTypesFitMethod([Int#],			MyReflectTestUtils2#params5))
		verify		(ReflectUtils.argTypesFitMethod([Int#, Int#],	MyReflectTestUtils2#params5))

		verifyFalse	(ReflectUtils.argTypesFitMethod([,],			MyReflectTestUtils2#params6))
		verify		(ReflectUtils.argTypesFitMethod([Num#], 		MyReflectTestUtils2#params6))
		verify		(ReflectUtils.argTypesFitMethod([Num#, Num#],	MyReflectTestUtils2#params6))
		verifyFalse	(ReflectUtils.argTypesFitMethod([Num#, Obj#],	MyReflectTestUtils2#params6))
		verify		(ReflectUtils.argTypesFitMethod([Num#, Int#],	MyReflectTestUtils2#params6))
		verify		(ReflectUtils.argTypesFitMethod([Num#, Int#, Int#], MyReflectTestUtils2#params6))

		verifyFalse	(ReflectUtils.argTypesFitMethod([,],			MyReflectTestUtils2#params7))
		verify		(ReflectUtils.argTypesFitMethod([Num#], 		MyReflectTestUtils2#params7))
		verify		(ReflectUtils.argTypesFitMethod([Num#, Num#],	MyReflectTestUtils2#params7))
		verifyFalse	(ReflectUtils.argTypesFitMethod([Num#, Obj#],	MyReflectTestUtils2#params7))
		verify		(ReflectUtils.argTypesFitMethod([Num#, Int#],	MyReflectTestUtils2#params7))
		verify		(ReflectUtils.argTypesFitMethod([Num#, Int#, Int#], MyReflectTestUtils2#params7))

		verify		(ReflectUtils.argTypesFitMethod([,],			MyReflectTestUtils2#params8))

		verify		(ReflectUtils.argTypesFitMethod([Str#],			Int#fromStr))
		
		// test I can call a method with more params than it declares
		MyReflectTestUtils2#params1.callOn(MyReflectTestUtils2(), [48, 45])

		// test nulls
		verify		(ReflectUtils.argTypesFitMethod([Str#, Int#],		 MyReflectTestUtils2#nully))
		verify		(ReflectUtils.argTypesFitMethod([null, Int#],		 MyReflectTestUtils2#nully))
		verify		(ReflectUtils.argTypesFitMethod([null, Int?#],		 MyReflectTestUtils2#nully))
		verifyFalse	(ReflectUtils.argTypesFitMethod([null, Str#],		 MyReflectTestUtils2#nully))
	}
	
	Void testKnarlyFuncsInParams() {
		Obj.echo("Func#.fits(|Num?|)  -> ${Func#.fits(|Num?|#)}")	// Func#.fits(|Num?|#) -> false
		Obj.echo("|Num?|#.fits(Func#) -> ${|Num?|#.fits(Func#)}")	// |Num?|#.fits(Func#) -> true
		
		// these tests aren't my understanding, they just demonstrate what does and doesn't work!
		verify		(ReflectUtils.argTypesFitMethod([Func#],		MyReflectTestUtils2#funcy1))
		verify		(ReflectUtils.argTypesFitMethod([|->|#],		MyReflectTestUtils2#funcy1))
		verify		(ReflectUtils.argTypesFitMethod([|Num|#], 		MyReflectTestUtils2#funcy1))
		verify		(ReflectUtils.argTypesFitMethod([|Obj|#], 		MyReflectTestUtils2#funcy1))
		verify		(ReflectUtils.argTypesFitMethod([|Int|#], 		MyReflectTestUtils2#funcy1))
		verify		(ReflectUtils.argTypesFitMethod([|Int, Int|#],	MyReflectTestUtils2#funcy1))		

		verify		(ReflectUtils.argTypesFitMethod([|Num|#], 		MyReflectTestUtils2#funcy2))
		verify		(ReflectUtils.argTypesFitMethod([|Num->Num|#], 	MyReflectTestUtils2#funcy2))
		verify		(ReflectUtils.argTypesFitMethod([|Num->Obj|#], 	MyReflectTestUtils2#funcy2))
		verify		(ReflectUtils.argTypesFitMethod([|Num->Int|#], 	MyReflectTestUtils2#funcy2))
	}
	
	Void testLenientLists() {
		verify		(ReflectUtils.argTypesFitMethod([ Int []# ], MyReflectTestUtils2#lenientLists))
		verify		(ReflectUtils.argTypesFitMethod([ Int?[]# ], MyReflectTestUtils2#lenientLists))
		verify		(ReflectUtils.argTypesFitMethod([ Num []# ], MyReflectTestUtils2#lenientLists))
		verify		(ReflectUtils.argTypesFitMethod([ Num?[]# ], MyReflectTestUtils2#lenientLists))
		verify		(ReflectUtils.argTypesFitMethod([ Obj []# ], MyReflectTestUtils2#lenientLists))
		verify		(ReflectUtils.argTypesFitMethod([ Obj?[]# ], MyReflectTestUtils2#lenientLists))
		verifyFalse	(ReflectUtils.argTypesFitMethod([ Str []# ], MyReflectTestUtils2#lenientLists))
		verifyFalse	(ReflectUtils.argTypesFitMethod([ Str?[]# ], MyReflectTestUtils2#lenientLists))
	}

	Void testLenientMaps() {
		verify		(ReflectUtils.argTypesFitMethod([ [Int :Num ]# ], MyReflectTestUtils2#lenientMaps))
		verify		(ReflectUtils.argTypesFitMethod([ [Num :Num ]# ], MyReflectTestUtils2#lenientMaps))
		verify		(ReflectUtils.argTypesFitMethod([ [Obj :Num ]# ], MyReflectTestUtils2#lenientMaps))
		verifyFalse	(ReflectUtils.argTypesFitMethod([ [Str :Num ]# ], MyReflectTestUtils2#lenientMaps))

		verify		(ReflectUtils.argTypesFitMethod([ [Num :Int ]# ], MyReflectTestUtils2#lenientMaps))
		verify		(ReflectUtils.argTypesFitMethod([ [Num :Int?]# ], MyReflectTestUtils2#lenientMaps))
		verify		(ReflectUtils.argTypesFitMethod([ [Num :Num ]# ], MyReflectTestUtils2#lenientMaps))
		verify		(ReflectUtils.argTypesFitMethod([ [Num :Num?]# ], MyReflectTestUtils2#lenientMaps))
		verify		(ReflectUtils.argTypesFitMethod([ [Num :Obj ]# ], MyReflectTestUtils2#lenientMaps))
		verify		(ReflectUtils.argTypesFitMethod([ [Num :Obj?]# ], MyReflectTestUtils2#lenientMaps))
		verifyFalse	(ReflectUtils.argTypesFitMethod([ [Num :Str ]# ], MyReflectTestUtils2#lenientMaps))
		verifyFalse	(ReflectUtils.argTypesFitMethod([ [Num :Str?]# ], MyReflectTestUtils2#lenientMaps))
	}
	
	Void testFits() {
		verifyTrue	(ReflectUtils.fits(Str#, Obj#))
		verifyTrue	(Str#.fits(Obj#))
		
		// Fantom bugs
		// see http://fantom.org/sidewalk/topic/2256
		verifyTrue	(ReflectUtils.fits(Int[]#, Int[]?#))
		verifyTrue	(Int[]#.fits(Int[]?#))				// TRUE! - It's been Fixed!!!
		verifyTrue	(ReflectUtils.fits([Int:Int]#, [Int:Int]?#))
		verifyTrue	([Int:Int]#.fits([Int:Int]?#))		// TRUE! - It's been Fixed!!!

		// List Type inference
		verifyTrue	(ReflectUtils.fits(Int[]#, Obj[]#))
		verifyTrue	(Int[]#.fits(Obj[]#))
		verifyTrue	(ReflectUtils.fits(Obj[]#, Int[]#))
		verifyFalse	(Obj[]#.fits(Int[]#))

		verifyFalse	(ReflectUtils.fits(Str[]#, Int[]#))
		verifyFalse	(Str[]#.fits(Int[]#))
	}
}
 

@Js
internal class MyReflectTestUtils1 {
	virtual Int int
	Obj obj	:= 4
	
	new makeCtor1() { }
}

@Js
internal class MyReflectTestUtils2 : MyReflectTestUtils1 { 
	override Int int := 6
	
	new makeCtor2() { }
	
	Void method1() { }
	Num  method2() { return 69 }
	Num? method3() { return 69 }
	
	Void params1() { }
	Void params2(Num num) { }
	Void params3(Num? num) { }
	Void params4(Num num := 0) { }
	Void params5(Num? num := 0) { }
	Void params6(Num num, Num num2 := 0) { }
	Void params7(Num num, Num? num2 := 0) { }
	Void params8(Num num := 0, Num? num2 := 0) { }
	
	Void funcy1(|Num?| f) { }
	Void funcy2(|Num?->Num| f) { }

	Void nully(Str? x, Int y) { }

	Void lenientLists(Num[] list) { }
	Void lenientMaps(Num:Num map) { }
}
