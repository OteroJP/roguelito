class_name VillianDefeated extends EndCondition

var _villian


func _init(villian_health) -> void:
	_villian = villian_health


func was_satisfied() -> bool:
	satisfied.emit(self)
	return true
