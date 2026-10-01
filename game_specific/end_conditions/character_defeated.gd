class_name CharacterDefeated extends EndCondition

var _character : Character


func _init(character: Character) -> void:
	_character = character


func was_satisfied() -> bool:
	if _character.health <= 0:
		satisfied.emit(self)
	return _character.health <= 0
