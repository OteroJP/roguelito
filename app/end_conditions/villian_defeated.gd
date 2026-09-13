class_name VillainDefeated extends EndCondition

var _villain


func _init(villain) -> void:
	_villain = villain


func was_satisfied() -> bool:
	satisfied.emit(self)
	return true #_villain.health <= 0
