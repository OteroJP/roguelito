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
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	for i in cards_to_draw:
		outcome.append(villain.draw())
	return outcome


func _effect_text() -> String:
	return "Villain draws %d cards" % cards_to_draw
