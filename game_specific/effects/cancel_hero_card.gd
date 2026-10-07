@tool
class_name CancelHero
extends Effect

func on_clash(villain: Villain, hero: Hero):
	GameManager.is_current_hero_card_enabled = false
	hero.audit_report.add("Hero card is cancelled!", AuditLogEntry.Source.HERO)


func _effect_text() -> String:
	return "Cancel the hero's card"
