@tool
class_name CancelVillain
extends Effect


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	GameManager.is_current_villain_card_enabled = false
	outcome.add(AuditEvent.Kind.CARD_CANCELLED, AuditLogEntry.Source.VILLAIN)


	return outcome


func _effect_text() -> String:
	return "Cancel the villain's card"
