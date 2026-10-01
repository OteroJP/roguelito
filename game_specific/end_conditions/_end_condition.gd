@abstract class_name EndCondition extends RefCounted

signal satisfied(condition: EndCondition)


@abstract func was_satisfied() -> bool

## This should be called to know if an [EndCondition] was satisfied. 
## It depends on an abstraction.
func report() -> void:		
	if was_satisfied():
		satisfied.emit(self)	
