
** A simple implementation of `NotFoundErr` that extends 'ArgErr'.
//@Js	// 'cos we can't subclass ArgErr in JS - http://fantom.org/forum/topic/2468
const class ArgNotFoundErr : ArgErr, NotFoundErr {
	override const Str?[] availableValues
	
	new make(Str msg, Obj?[] availableValues, Err? cause := null) : super.make(msg, cause) {
		this.availableValues = availableValues.map { it?.toStr }.sort
	}
	
	override Str toStr() {
		NotFoundErr.super.toStr		
	}
}
