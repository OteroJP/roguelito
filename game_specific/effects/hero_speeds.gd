@tool
class_name HeroSpeeds
extends Effect
## Increases should always be multiple of 2 so there are no ties

@export var speed_modification: int


func _on_clash(
	_villain: Villain,
	_hero: Hero,
	_villain_port: VillainPort,
	hero_port: HeroPort,
	combat_manager: CombatManager
) -> void:
	combat_manager.add_speed_bonus(hero_port, speed_modification)




func _effect_text() -> String:
	if speed_modification < 0:
		return "Hero loses %d speed" % absi(speed_modification)
	return "Hero gains %d speed" % speed_modification
