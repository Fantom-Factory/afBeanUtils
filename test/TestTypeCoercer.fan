
@Js
internal class TestTypeCoercer : BeanTest {
	
	Void testCoerce() {
		tc := TypeCoercer()

		// same obj
		verifyEq(tc.coerce(69, Num#), 69)
		verifyEq(tc.coerce(69f, Num#), 69f)

		// toXXX()
		verifyEq(tc.coerce(69, Str#), "69")
		verifyEq(tc.coerce(69f, Str#), "69.0")
		verifyEq(tc.coerce("69", Int#), 69)
		if (Env.cur.runtime != "js")
			verifyEq(tc.coerce(`69`, File#), `69`.toFile)

		// fromXXX()
		verifyEq(tc.coerce("2000-01-01T00:00:00Z UTC", DateTime#), DateTime.defVal)
		
		// no coersion
		verifyErrMsg(ArgErr#, "Could not find coercion from afBeanUtils::TestTypeCoercer to Int") {
			tc.coerce(this, Int#)
		}
		
		// nulls
		verifyNull(tc.coerce(null, Str?#))
		verifyErrMsg(ArgErr#, "Could not find coercion from null to Str") |t| {
			verifyEq(tc.coerce(null, Str#), null)
		}

		// test cache doesn't fail conversion
		verifyEq(tc.coerce(69, Str#), "69")
		verifyEq(tc.coerce("2000-01-01T00:00:00Z UTC", DateTime#), DateTime.defVal)		
	}
	
	Void testCanCoerce() {
		tc := TypeCoercer()
		
		verify     (tc.canCoerce(Str#, Int#))
		verifyFalse(tc.canCoerce(TestTypeCoercer#, Int#))
		
		// test cache 
		verify     (tc.canCoerce(Str#, Int#))
		verifyFalse(tc.canCoerce(TestTypeCoercer#, Int#))
		
		// test nulls
		verify     (tc.canCoerce(null, null))
		verify     (tc.canCoerce(null, Int?#))
		verifyFalse(tc.canCoerce(null, Int#))
		verify     (tc.canCoerce(Int?#, null))
		verifyFalse(tc.canCoerce(Int#, null))
	}

	Void testCanCoerceLists() {
		tc := TypeCoercer()
		
		verify     (tc.canCoerce(Str[]#, Int[]#))
		verifyFalse(tc.canCoerce(TestTypeCoercer[]#, Int[]#))
		
		// test cache 
		verify     (tc.canCoerce(Str[]#, Int[]#))
		verifyFalse(tc.canCoerce(TestTypeCoercer[]#, Int[]#))
		
		// test non-parameterised lists
		verify     (tc.canCoerce(Str[]#, List#))
	}

	Void testCoerceLists() {
		tc := TypeCoercer()

		// same obj
		verifyEq(tc.coerce([69], Int[]#), [69])
		verifyEq(tc.coerce([69f], Float[]#), [69f])

		// toXXX()
		verifyEq(tc.coerce([69, 42], Str[]#), ["69", "42"])
		verifyEq(tc.coerce([69f, 42f], Str[]#), ["69.0", "42.0"])
		verifyEq(tc.coerce(["69", "42"], Int[]#), [69, 42])
		verifyEq(tc.coerce(["69", null], Int?[]#), [69, null])

		// no coersion
		verifyErrMsg(ArgErr#, "Could not find coercion from afBeanUtils::TestTypeCoercer to Int") {
			tc.coerce([this], Int[]#)
		}
		
		// test cache doesn't fail conversion
		verifyEq(tc.coerce([69, 42], Str[]#), ["69", "42"])
		verifyEq(tc.coerce(["69", "42"], Int[]#), [69, 42])

		// test non-parameterised lists
		verifyEq(tc.coerce([69], List#), Obj?[69])
	}
	
	Void testCoerceEmptyLists() {
		tc := TypeCoercer()

		verifyEq(tc.coerce(Int[,], Str[]#), Str[,])
		verifyEq(tc.coerce(Obj[,], Str[]#), Str[,])
		verifyEq(tc.coerce(Int[,], Obj[]#), Obj[,])
	}

	Void testCoerceMaps() {
		tc := TypeCoercer()

		// same obj
		verifyEq(tc.coerce([6:9], Int:Int#), [6:9])
		verifyEq(tc.coerce([6:9f], Int:Float#), [6:9f])

		// toXXX()
		verifyEq(tc.coerce([6:9, 4:2], Str:Str#), ["6":"9", "4":"2"])
		verifyEq(tc.coerce([6:9f, 4:2f], Str:Str#), ["6":"9.0", "4":"2.0"])
		verifyEq(tc.coerce(["6":"9", "4":"2"], Int:Int?#), Int:Int?[6:9, 4:2])
		if (Env.cur.runtime != "js")
			verifyEq(tc.coerce([`6`:`9`, `4`:null], File:File?#), [`6`.toFile:`9`.toFile, `4`.toFile:null])

		// no coersion
		verifyErrMsg(ArgErr#, "Could not find coercion from afBeanUtils::TestTypeCoercer to Int") {
			tc.coerce([2:this], Int:Int#)
		}
		
		// test cache doesn't fail conversion
		verifyEq(tc.coerce([6:9, 4:2], Str:Str#), ["6":"9", "4":"2"])
		verifyEq(tc.coerce(["6":"9", "4":"2"], Int:Int?#), Int:Int?[6:9, 4:2])
		
		// test non-parameterised maps
		verifyEq(tc.coerce([6:9], Map#), Obj:Obj?[6:9])
	}
	
	Void testCoerceEmptyMaps() {
		tc := TypeCoercer()

		// keys
		verifyEq(tc.coerce(Int:Obj[:], [Str:Obj]#), Str:Obj[:])
		verifyEq(tc.coerce(Obj:Obj[:], [Str:Obj]#), Str:Obj[:])
		verifyEq(tc.coerce(Int:Obj[:], [Obj:Obj]#), Obj:Obj[:])

		// vals
		verifyEq(tc.coerce(Obj:Int[:], [Obj:Str]#), Obj:Str[:])
		verifyEq(tc.coerce(Obj:Obj[:], [Obj:Str]#), Obj:Str[:])
		verifyEq(tc.coerce(Obj:Int[:], [Obj:Obj]#), Obj:Obj[:])
	}
}
