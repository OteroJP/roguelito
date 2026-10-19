@tool
class_name RevealHero
extends Effect


func _ask_for_interaction(
	_villain_port: VillainPort,
	hero_port: HeroPort,
	_combat_manager: CombatManager
) -> AuditOutcome:
	await hero_port.reveal_played_card()
	return AuditOutcome.new()


func _on_clash(
	_villain: Villain,
	_hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()


	return outcome


func _effect_text() -> String:
	return "Reveal the hero's card"
