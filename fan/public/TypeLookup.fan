
** A helper class that looks up Objs via Type inheritance search.
const class TypeLookup {	
	private const Type:Obj? 	values
	
	** Creates an TypeLookup with the given map. All types are coerced to non-nullable types.
	** An 'ArgErr' is thrown if a duplicate is found in the process. 
	new make(Type:Obj? values) {
		nonDups := [Type:Obj?][:]
		values.each |val, type| {
			nonNullable := type.toNonNullable
			if (nonDups.containsKey(nonNullable)) 
				throw ArgErr("Type $nonNullable is already mapped to value ${nonDups[nonNullable]}")
			nonDups[nonNullable] = val
		}
		this.values = nonDups.toImmutable
	}

	** Standard Map behaviour - looks up an Obj via the type. 
	Obj? findExact(Type exact, Bool checked := true) {
		nonNullable := exact.toNonNullable
		return values.get(nonNullable)
			?: check(nonNullable, checked)
	}

	** Returns the value of the closest parent of the given type.
	** Example:
	** pre>
	**   strategy := StrategyRegistry( [Obj#:1, Num#:2, Int#:3] )
	**   strategy.findClosestParent(Obj#)   // --> 1
	**   strategy.findClosestParent(Num#)   // --> 2
	**   strategy.findClosestParent(Float#) // --> 2
	** <pre
	Obj? findParent(Type type, Bool checked := true) {
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
	
	** Returns the values of the children of the given type.
	** Example:
	** pre>
	**   strategy := StrategyRegistry( [Obj#:1, Num#:2, Int#:3] )
	** 	 strategy.findChildrenOf(Obj#)   // --> [1, 2, 3]
	**   strategy.findChildrenOf(Num#)   // --> [2, 3]
	**   strategy.findChildrenOf(Float#) // --> [,]
	** <pre
	** 
	** If no children are found, an empty list is returned.
	Obj?[] findChildren(Type type) {
		nonNullable := type.toNonNullable
		return values.findAll |val, key| { key.fits(type) }.vals
	}
	
	private Obj? check(Type nonNullable, Bool checked) {
		checked ? throw TypeNotFoundErr("Could not find match for Type ${nonNullable}.", values.keys) : null
	}
	
	@NoDoc
	override Str toStr() {
		values.keys.toStr
	}
}

@NoDoc
const class TypeNotFoundErr : Err, NotFoundErr {
	override const Str?[] availableValues
	
	new make(Str msg, Obj?[] availableValues, Err? cause := null) : super(msg, cause) {
		this.availableValues = availableValues.map { it?.toStr }.sort
	}
	
	override Str toStr() {
		NotFoundErr.super.toStr
	}
}
