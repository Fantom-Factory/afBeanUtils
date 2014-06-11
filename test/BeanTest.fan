
internal class BeanTest : Test {
	
	Void verifyTrue(Bool cond, Str? msg := null) {
		verify(cond, msg)
	}

	Void verifyErrMsg(Type errType, Str errMsg, |Obj| func) {
		try {
			func(4)
			fail("$errType not thrown")
		} catch (Err e) {
			try {
				verify(e.typeof.fits(errType), "Expected $errType got $e.typeof")
//				verifyEq(e.msg.splitLines.first.trim, errMsg.trim, "Expected: \n - $errMsg \nGot: \n - $e.msg")
				verifyEq(e.msg.splitLines.first.trim, errMsg.trim)
			} catch (Err failure) {
				throw Err(failure.msg, e)
			}
		}
	}

}
