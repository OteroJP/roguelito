@tool
class_name CancelVillain
extends Effect


func _on_clash(
	_villain: Villain,
	_hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	combat_manager: CombatManager
) -> void:
	combat_manager.cancel_villain_card()




func _effect_text() -> String:
	return "Cancel the villain's card"
