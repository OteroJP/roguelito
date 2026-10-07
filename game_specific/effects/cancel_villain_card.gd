@tool
class_name CancelVillain
extends Effect

func on_clash(villain: Villain, hero: Hero):
	GameManager.is_current_villain_card_enabled = false
	villain.audit_report.add("Villain card is cancelled!", AuditLogEntry.Source.VILLAIN)


func _effect_text() -> String:
	return "Cancel the villain's card"
