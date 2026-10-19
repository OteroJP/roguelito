@tool
class_name CancelHero
extends Effect


func _on_clash(
	_villain: Villain,
	_hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	GameManager.is_current_hero_card_enabled = false
	outcome.add(AuditEvent.Kind.CARD_CANCELLED, AuditLogEntry.Source.HERO)


	return outcome


func _effect_text() -> String:
	return "Cancel the hero's card"
