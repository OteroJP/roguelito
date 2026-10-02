@tool
class_name CancelHero
extends Effect

func on_clash(villain: Villain, hero: Hero):
	GameManager.is_current_hero_card_enabled = false
	GameManager.add_debug("Hero card is cancelled!", GameManager.LogSource.HERO)


func _effect_text() -> String:
	return "Cancel the hero's card"
