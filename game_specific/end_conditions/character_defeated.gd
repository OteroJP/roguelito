class_name CharacterDefeated extends EndCondition

var character: Character


func _init(character_to_watch: Character) -> void:
	character = character_to_watch


func was_satisfied() -> bool:
	if character.health <= 0:
		satisfied.emit(self)
	return character.health <= 0
