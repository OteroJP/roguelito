@tool
class_name VillainDraw
extends Effect

@export var cards_to_draw: int = 1


func _on_clash(
	villain: Villain,
	_hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> void:
	for i in cards_to_draw:
		villain.draw()


func _effect_text() -> String:
	return "Villain draws %d cards" % cards_to_draw
