@tool
class_name VillainCardData
extends CardData

@export var symbol_to_complete: Villain.Symbol
@export var symbol_to_spawn: Villain.Symbol


func bonus_condition_met(character: Character) -> bool:
	assert(character is Villain, "VillainCardData requires a Villain character.")
	return (character as Villain).is_in_second_phase()


func _bonus_color() -> Color:
	return UIAssets.VILLAIN_SECOND_PHASE_COLOR
