@tool
class_name VillainSpeeds
extends Effect
## Increases should always be multiple of 2 so there are no ties

@export var speed_modification: int


func _on_clash(
	_villain: Villain,
	_hero: Hero,
	villain_port: VillainPort,
	_hero_port: HeroPort,
	combat_manager: CombatManager
) -> void:
	combat_manager.add_speed_bonus(villain_port, speed_modification)




func _effect_text() -> String:
	if speed_modification < 0:
		return "Villain loses %d speed" % absi(speed_modification)
	return "Villain gains %d speed" % speed_modification
