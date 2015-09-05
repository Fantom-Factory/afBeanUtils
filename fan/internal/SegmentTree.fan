
internal class SegmentTree {
	Str 				expression
	SegmentFactory?		segmentFactory
	Str:SegmentTree		branches		:= [:]
	SegmentFactory:Obj?	leaves			:= [:]
	|Type->BeanFactory|	factoryFunc
	
	new make(SegmentFactory? segmentFactory, |Type->BeanFactory|? factoryFunc) {
		this.segmentFactory = segmentFactory
		this.expression 	= segmentFactory?.expression ?: "root"
		this.factoryFunc	= factoryFunc ?: |Type type->BeanFactory| { BeanFactory(type) } 
	}
	
	Obj? create(Type type, Obj? instance) {
		beanFactory := (instance == null) ? factoryFunc.call(type) : null
	
		branches.each |tree| {
			if (tree.segmentFactory.type(type) == SegmentType.field) {
				segment := (ExecuteField) tree.segmentFactory.makeSegment(type, instance, false)
				value	:= tree.create(segment.returns, null)
				
				if (instance == null) {
					beanFactory[segment.field] = segment.coerceValue(value)
				} else
					segment.set(value)
			}
		}
		
		leaves.each |value, segmentFactory| {
			if (segmentFactory.type(type) == SegmentType.field) {
				segment := (ExecuteField) segmentFactory.makeSegment(type, instance, true)

				if (instance == null) {
					beanFactory[segment.field] = segment.coerceValue(value)
				} else
					segment.set(value)
			}
		}
			
		instance = beanFactory?.create ?: instance
		
		branches.each |SegmentTree tree| {
			if (tree.segmentFactory.type(type) == SegmentType.index) {
				segment := tree.segmentFactory.makeSegment(type, instance, false)
				value	:= tree.create(segment.returns, null)
				segment.set(value)
			}
		}

		branches.each |SegmentTree tree| {
			if (tree.segmentFactory.type(type) == SegmentType.method) {
				segment := tree.segmentFactory.makeSegment(type, instance, false)
				inst 	:= segment.get(null)
				value	:= tree.create(segment.returns, inst)
				// nothing to set!
			}
		}
		
		leaves.each |value, segmentFactory| {
			if (segmentFactory.type(type) == SegmentType.index) {
				segment := segmentFactory.makeSegment(type, instance, true)
				segment.set(value)
			}
		}

		leaves.each |value, segmentFactory| {
			if (segmentFactory.type(type) == SegmentType.method) {
				segment := segmentFactory.makeSegment(type, instance, true)
				// this just throws an err
				segment.set(value)
			}
		}
		
		return instance 
	}	
}
