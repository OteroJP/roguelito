@tool
class_name CancelHero
extends Effect


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	GameManager.is_current_hero_card_enabled = false
	outcome.add(AuditEvent.Kind.CARD_CANCELLED, AuditLogEntry.Source.HERO)


	return outcome


func _effect_text() -> String:
	return "Cancel the hero's card"
