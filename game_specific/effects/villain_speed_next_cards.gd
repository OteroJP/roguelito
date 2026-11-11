@tool
class_name VillainSpeedNext
extends Effect

@export var bonus_speed: int = 0



func combat_state_changes(_effect_owner: Character) -> Array[CombatStateChange]:
	var change := CombatStateChange.new(target_side)
	change.speed_bonus_to_add = bonus_speed
	return [change]


func _effect_text() -> String:
    return "Villain gains +%s speed" % str(bonus_speed)
