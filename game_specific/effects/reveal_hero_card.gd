@tool
class_name RevealHero
extends Effect


func _ask_for_interaction(
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	combat_manager: CombatManager
) -> void:
	combat_manager.reveal_hero_card()


func _on_clash(
	_villain: Villain,
	_hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> void:
	pass




func _effect_text() -> String:
	return "Reveal the hero's card"
