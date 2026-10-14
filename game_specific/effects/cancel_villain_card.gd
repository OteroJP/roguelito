@tool
class_name CancelVillain
extends Effect


func _on_clash(
	_villain: Villain,
	_hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	GameManager.is_current_villain_card_enabled = false
	outcome.add(AuditEvent.Kind.CARD_CANCELLED, AuditLogEntry.Source.VILLAIN)


	return outcome


func _clear_effect_data() -> void:
	pass


func _effect_text() -> String:
	return "Cancel the villain's card"
