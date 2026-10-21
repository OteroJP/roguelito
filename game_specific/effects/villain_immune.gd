@tool
class_name VillainImmune
extends Effect


func _on_clash(
	villain: Villain,
	_hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> void:
	villain.immune_to_damage = true




func _effect_text() -> String:
	return "Villain is immune to damage"
