
internal class ErrMsgs {

	static Str typeCoercer_fail(Type from, Type to) {
		stripSys("Could not coerce ${from.qname} to ${to.qname}")
	}
	
	static Str typeCoercer_notFound(Type? from, Type to) {
		stripSys("Could not find coercion from ${from?.qname} to ${to.signature}")
	}
	
	static Str property_crazy(Int index, Type listType, Field field) {
		stripSys("Are you CRAZY!? Do you *really* want to create ${index} instances of ${listType} for ${field.qname}???")
	}

	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
