
** Looks up values via a type inheritance search.
** 
** Example, if a 'TypeLookup' was created with 'Obj#, Num#' and 'Int#', the inheritance and 
** matching types would look like:
** 
** pre>
** Type  findParent()  findChildren()
** 
** Obj   Obj           Obj, Num, Int
**  | 
** Num   Num           Num, Int
**  |
** Int   Int           Int
** <pre
** 
** Note that 'findParent()' and 'findChildren()' return the value associated with the type, not the 
** type itself. They also match the given type if 'TypeLookup' was created with it, hence 
** 'findParent()' above matches itself.
** 
** While the above results are quite obvious, 'TypeLookup' is more useful when passed a type it 
** doesn't know about:  
** 
**   findParent(Float#)    // --> Num#
**   findChildren(Float#)  // --> Err
** 
** When searching the type hierarchy for a closest match (see 'findParent()' ), note that 
** 'TypeLookup' also searches mixins.
** 
** Example usages can be found in:
**  - [IoC]`http://www.fantomfactory.org/pods/afIoc`: All known implementations of a mixin are looked up via 'findChildren()'
**  - [BedSheet]`http://www.fantomfactory.org/pods/afBedSheet`: Strategies for handling Err types are looked up via 'findParent()'
**
** If performance is required, then use [Concurrent]`http://www.fantomfactory.org/pods/afConcurrent` 
** to create a 'TypeLookup' that caches the lookups. 
** Full code for a 'CachingTypeLookup' is given below: 
**  
** pre>
** using afBeanUtils
** using afConcurrent
** 
** ** A 'TypeLookup' that caches the lookup results.
** internal const class CachingTypeLookup : TypeLookup {
**     private const AtomicMap parentCache   := AtomicMap()
**     private const AtomicMap childrenCache := AtomicMap()
** 
**     new make(Type:Obj? values) : super(values) { }
**     
**     ** Cache the lookup results
**     override Obj? findParent(Type type, Bool checked := true) {
**         nonNullable := type.toNonNullable
**         return parentCache.getOrAdd(nonNullable) { doFindParent(nonNullable, checked) } 
**     }
**     
**     ** Cache the lookup results
**     override Obj?[] findChildren(Type type, Bool checked := true) {
**         nonNullable := type.toNonNullable
**         return childrenCache.getOrAdd(nonNullable) { doFindChildren(nonNullable, checked) } 
**     }
** 
**     ** Clears the lookup cache 
**     Void clear() {
**         parentCache.clear
**         childrenCache.clear
**     }
** }
** <pre
@Js
const class TypeLookup {	
	private const Type:Obj? 	values
	
	** Creates a 'TypeLookup' with the given map. All types are coerced to non-nullable types.
	** An 'ArgErr' is thrown if a duplicate is found in the process. 
	new make(Type:Obj? values) {
		values  = values.rw
		nonDups := Type:Obj?[:]
		nonDups.ordered = values.ordered	// mainly for testing, lookup is faster when not ordered 
		values.each |val, type| {
			nonNullable := type.toNonNullable
			if (nonDups.containsKey(nonNullable)) 
				throw ArgErr("Type $nonNullable is already mapped to value ${nonDups[nonNullable]}")
			nonDups[nonNullable] = val
		}
		this.values = nonDups
	}

	** Returns the value that matches the given type. This is just standard Map behaviour.
	**  
	** If no match is found and 'checked' is 'false', 'null' is returned.
	Obj? findExact(Type exact, Bool checked := true) {
		nonNullable := exact.toNonNullable
		return values.get(nonNullable) ?: check(nonNullable, checked)
	}

	** Returns the value of the closest parent of the given type (or the given type should ).
	** Example:
	** pre>
	**   strategy := StrategyRegistry( [Obj#:1, Num#:2, Int#:3] )
	**   strategy.findClosestParent(Obj#)     // --> 1
	**   strategy.findClosestParent(Num#)     // --> 2
	**   strategy.findClosestParent(Float#)   // --> 2
	**   strategy.findClosestParent(Wotever#) // --> Err
	** <pre
	** 
	** If no parent is found and 'checked' is 'false', 'null' is returned.
	virtual Obj? findParent(Type type, Bool checked := true) {
		doFindParent(type, checked)
	}
	
	** Returns the values of the children of the given type.
	** Example:
	** pre>
	**   strategy := StrategyRegistry( [Obj#:1, Num#:2, Int#:3] )
	** 	 strategy.findChildren(Obj#)     // --> [1, 2, 3]
	**   strategy.findChildren(Num#)     // --> [2, 3]
	**   strategy.findChildren(Float#)   // --> Err
	** <pre
	** 
	** If no children are found and 'checked' is 'false', an empty list is returned.
	virtual Obj?[] findChildren(Type type, Bool checked := true) {
		doFindChildren(type, checked)
	}
	
	** It kinda sucks to need this method, but it's a workaround to 
	** [this issue]`http://fantom.org/sidewalk/topic/2289`.
	@NoDoc
	protected Obj? doFindParent(Type type, Bool checked := true) {
		nonNullable := type.toNonNullable

		// chill, I got tests for all this!
		deltas := values
			.findAll |val, t2| { nonNullable.fits(t2) }
			.map |val, t2->Int?| {
				nonNullable.inheritance.eachWhile |sup, i| {
					(sup == t2 || sup.mixins.contains(t2)) ? i : null
				}
			}
		
		if (deltas.isEmpty)
			return check(nonNullable, checked)
		
		minDelta := deltas.vals.min
		match 	 := deltas.eachWhile |delta, t2| { (delta == minDelta) ? t2 : null }
		return values[match]
	}
	
	** It kinda sucks to need this method, but it's a workaround to 
	** [this issue]`http://fantom.org/sidewalk/topic/2289`.
	@NoDoc
	protected Obj?[] doFindChildren(Type type, Bool checked := true) {
		nonNullable := type.toNonNullable
		children := values.findAll |val, key| { key.fits(type) }.vals
		return !children.isEmpty ? children : (check(nonNullable, checked) ?: Obj?#.emptyList)
	}
	
	private Obj? check(Type nonNullable, Bool checked) {
		checked ? throw TypeNotFoundErr("Could not find match for Type ${nonNullable}.", values.keys) : null
	}
	
	@NoDoc
	override Str toStr() {
		values.keys.toStr
	}
}

** This Err is left public just in case someone wants to catch it.
@Js @NoDoc
const class TypeNotFoundErr : Err, NotFoundErr {
	override const Str?[] availableValues
	
	new make(Str msg, Obj?[] availableValues, Err? cause := null) : super(msg, cause) {
		this.availableValues = availableValues.map { it?.toStr }.sort
	}
	
	override Str toStr() {
		NotFoundErr.super.toStr
	}
}
