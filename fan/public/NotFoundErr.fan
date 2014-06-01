
** Implement on user defined Errs to list available values in the stack trace.   
** This gives the user helpful context when a value could not be found. 
** Typical usage would be:
**
** pre> 
** const class MyNotFoundErr : Err, NotFoundErr {
**    override const Str?[] availableValues
**    
**    new make(Str msg, Obj?[] availableValues, Err? cause := null) : super(msg, cause) {
**       this.availableValues = availableValues.map { it?.toStr }.sort
**    }
**    
**    override Str toStr() {
**       NotFoundErr.super.toStr
**    }
** }
** <pre
** 
** Which when thrown with: 
** 
**   throw MyNotFoundErr("Could not find a sausage.", ["steak", "hot dog", "burger"])
** 
** Gives a helpful stack trace of:
** 
** pre>
** MyNotFoundErr: Could not find a sausage.
** 
** Available values:
**   burger
**   hot dog
**   steak
** 
** Stack Trace:
**   afTest::Wotever.main (Wotever.fan:69)
**   java.lang.reflect.Method.invoke (Method.java:597)
**   fan.sys.Method.invoke (Method.java:559)
**   fan.sys.Method$MethodFunc.callOn (Method.java:230)
**   fanx.tools.Fan.callMain (Fan.java:175)
**   fanx.tools.Fan.executeType (Fan.java:140)
**   ...
** <pre
** 
** Note that [BedSheet]`http://www.fantomfactory.org/pods/afBedSheet` gives special treatment to 
** 'NotFoundErrs' on its standard Err 500 page and lists the available values in its own section.  
const mixin NotFoundErr {

	** The standard 'Err' msg.
	abstract Str 	msg()
	
	** A list of values the user could have used chosen.
	abstract Str[]	availableValues()

	** Pre-pends the list of available values to the stack trace.
	override Str toStr() {
		buf := StrBuf()
		buf.add("${typeof.qname}: ${msg}\n")
		buf.add("\nAvailable values:\n")
		availableValues.each { buf.add("  $it\n")}
		buf.add("\nStack Trace:")
		return buf.toStr
	}
}
