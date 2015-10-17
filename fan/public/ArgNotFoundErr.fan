
** A simple implementation of `NotFoundErr`.
** This class can not extend 'ArgErr' due to [Cannot extend sys Errs in Javascript]`http://fantom.org/forum/topic/2468`.
@Js 
const class ArgNotFoundErr : Err, NotFoundErr {
	override const Str?[] availableValues
	
	new make(Str msg, Obj?[] availableValues, Err? cause := null) : super.make(msg, cause) {
		this.availableValues = availableValues.map { it?.toStr }.sort
	}
	
	override Str toStr() {
		NotFoundErr.super.toStr		
	}
}
