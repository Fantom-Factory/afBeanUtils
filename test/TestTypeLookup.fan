
internal class TestTypeLookup : BeanTest {
	
	Void testDupsError() {
		// need to get the ordering correct
		map := [Type:Obj?][:] { ordered = true }
		map[Err#] 		= 1
		map[ArgErr?#] 	= 2
		map[Err?#] 		= 3
		
		verifyErrMsg(ArgErr#, "Type sys::Err is already mapped to value 1") {
			ap := TypeLookup(map)
		}
	}
	
	Void testNoMacth() {
		map := [Type:Obj?][:] { ordered = true }
		map[ArgErr#] 	= 2
		map[Err#] 		= 1
		ap := TypeLookup(map)

		verifyEq(ap.findExact(Bool#, false), null)
	}
	
	Void testExactMacth() {
		map := [Type:Obj?][:] { ordered = true }
		map[ArgErr#] 	= 2
		map[Err#] 		= 1
		ap := TypeLookup(map)

		verifyEq(ap.findExact(Obj#, false), null)
		verifyEq(ap.findExact(Obj?#, false), null)
		verifyEq(ap.findExact(Err#, false), 1)
		verifyEq(ap.findExact(Err?#, false), 1)
		verifyEq(ap.findExact(ArgErr#, false), 2)
		verifyEq(ap.findExact(ArgErr?#, false), 2)
		verifyEq(ap.findExact(T_InnerArgErr#, false), null)
		verifyEq(ap.findExact(T_InnerArgErr?#, false), null)
		verifyEq(ap.findExact(TestTypeLookup?#, false), null)
		
		verifyErrMsg(TypeNotFoundErr#, "Could not find match for Type afBeanUtils::TestTypeLookup.") |t| {
			try {
				ap.findExact(TestTypeLookup#)
			} catch (TypeNotFoundErr nfe) {
				verifyEq(nfe.availableValues[0], "sys::ArgErr")
				verifyEq(nfe.availableValues[1], "sys::Err")
				verifyEq(nfe.availableValues.size, 2)
				throw nfe
			}
		}

		verifyErrMsg(TypeNotFoundErr#, "Could not find match for Type afBeanUtils::T_InnerArgErr.") |t| {
			try {
				ap.findExact(T_InnerArgErr#)
			} catch (TypeNotFoundErr nfe) {
				verifyEq(nfe.availableValues[0], "sys::ArgErr")
				verifyEq(nfe.availableValues[1], "sys::Err")
				verifyEq(nfe.availableValues.size, 2)
				throw nfe
			}
		}
	}

	Void testBestFit() {
		map := [Type:Obj?][:] { ordered = true }
		map[ArgErr#] 	= 2
		map[Err#] 		= 1
		map[T_StratA#] 	= 3
		ap := TypeLookup(map)

		verifyEq(ap.findParent(Obj#, false), null)
		verifyEq(ap.findParent(Obj?#, false), null)
		verifyEq(ap.findParent(Err#), 1)
		verifyEq(ap.findParent(Err?#), 1)
		verifyEq(ap.findParent(ArgErr#, false), 2)
		verifyEq(ap.findParent(ArgErr?#, false), 2)
		verifyEq(ap.findParent(T_InnerArgErr#, false), 2)
		verifyEq(ap.findParent(T_InnerArgErr?#, false), 2)
		verifyEq(ap.findParent(TestTypeLookup?#, false), null)

		verifyEq(ap.findParent(T_StratB?#, false), 3)
		verifyEq(ap.findParent(T_StratA?#, false), 3)	// should find A even though it's not directly in the map
		verifyEq(ap.findParent(T_StratC?#, false), 3)
		
		verifyErrMsg(TypeNotFoundErr#, "Could not find match for Type afBeanUtils::TestTypeLookup.") |t| {
			try {
				ap.findExact(TestTypeLookup#)
			} catch (TypeNotFoundErr nfe) {
				verifyEq(nfe.availableValues[0], "afBeanUtils::T_StratA")
				verifyEq(nfe.availableValues[1], "sys::ArgErr")
				verifyEq(nfe.availableValues[2], "sys::Err")
				verifyEq(nfe.availableValues.size, 3)
				throw nfe				
			}
		}
	}
	
	Void testDocs() {
		strategy := TypeLookup([:] { ordered=true; it[Obj#]=1; it[Num#]=2; it[Int#]=3})
		verifyEq(strategy.findParent(Obj#), 1)
		verifyEq(strategy.findParent(Num#), 2)
		verifyEq(strategy.findParent(Float#), 2)

		verifyEq(strategy.findChildren(Obj#),   Obj?[1, 2, 3])
		verifyEq(strategy.findChildren(Num#),   Obj?[2, 3])
		verifyEq(strategy.findChildren(Float#, false), Obj?[,])
	}
}

internal const mixin T_StratA { }
internal const class T_StratB : ArgErr, T_StratA { 
	new make(Str msg := "", Err? cause := null) : super(msg, cause) {}
}
internal const class T_StratC : T_StratB { 
	new make(Str msg := "", Err? cause := null) : super(msg, cause) {}
}

internal const class T_InnerArgErr : ArgErr {
	new make(Str msg := "", Err? cause := null) : super(msg, cause) {}
}