
@Js
internal class ErrMsgs {

	static Str property_badParse(Str input) {
		"Could not parse property string: ${input}"
	}

	static Str property_crazyList(Int index, Type listType, Field field) {
		stripSys("Are you CRAZY!? Do you *really* want to create ${index} instances of ${listType}??? \nSee ${field.qname} to change this limit, or create them yourself.")
	}

	static Str property_setOnMethod(Method method) {
		stripSys("Can not *set* a value on method: ${method.qname}")
	}

	static Str property_notMethod(Field field) {
		stripSys("Can not pass method arguments to a field: ${field.qname}")
	}

	static Str properties_couldNotMake(Type type) {
		stripSys("Could not instantiate $type.signature")
	}

	static Str factory_defValNotFound(Type type) {
		stripSys("${type.signature} is null and does not have a default value")
	}

	static Str factory_ctorWrongType(Type type, Method ctor) {
		stripSys("Ctor ${ctor.qname} does not belong to $type.qname")
	}

	static Str factory_ctorArgMismatch(Method ctor, Obj?[] args) {
		ctorSig := ctor.qname + "(" + ctor.params.join(", ") + ")"
		return stripSys("Arguments do not match ctor params for ${ctorSig} - ${args}")
	}

	static Str factory_noCtorsFound(Type type, Type?[] argTypes) {
		stripSys("Could not find a ctor on ${type.qname} to match argument types - ${argTypes}")
	}

	static Str factory_tooManyCtorsFound(Type type, Str[] ctorNames, Type?[] argTypes) {
		stripSys("Found more than 1 ctor on ${type.qname} ${ctorNames} that match argument types - ${argTypes}")
	}

	static Str factory_fieldWrongParent(Type type, Field field) {
		stripSys("Field ${field.qname} does not belong to ${type.qname}")
	}

	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
