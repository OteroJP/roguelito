@tool
class_name HeroHeals
extends Effect

@export var amount_to_heal: int

#TODO refactor to new attack system


func _on_clash(
	_villain: Villain,
	hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> void:
	hero.heal(amount_to_heal)




func _effect_text() -> String:
	return "Hero heals %d" % amount_to_heal
