@tool
class_name CharacterSpeedBonus
extends Effect
## Increases should always be multiples of 2 so there are no ties.

@export var speed_modification: int



func combat_state_changes(_effect_owner: Character) -> Array[CombatStateChange]:
	var change := CombatStateChange.new(target_side)
	change.speed_bonus_to_add = speed_modification
	return [change]


func _effect_text() -> String:
	var recipient := target_label().capitalize()
	if speed_modification < 0:
		return "%s loses %d speed" % [recipient, absi(speed_modification)]
	return "%s gains %d speed" % [recipient, speed_modification]
