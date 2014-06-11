
@Js
internal class OneShotLock {
	
	private Str 	because
			Bool	locked	{ private set }
	
	new make(Str because) {
		this.because = because
	}
	
	Void lock() {
		check	// you can't lock twice!
		locked = true
	}
	
	Void check() {
		if (locked)
			throw Err(ErrMsgs.oneShotLock_violation(because))
	}
	
	override Str toStr() {
		(locked ? "" : "(un)") + "locked"
	}
}