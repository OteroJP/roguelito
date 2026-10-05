@tool
class_name VillainSpeedNext
extends Effect

@export var bonus_speed: int = 0

func on_clash(villain: Villain, hero: Hero):
	villain.bonus_speed += bonus_speed

func _effect_text() -> String:
	var text := "Villain gains +%s speed" % str(bonus_speed)
	return text
