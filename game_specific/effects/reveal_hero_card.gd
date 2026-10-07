@tool
class_name RevealHero
extends Effect


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	GameManager.playing_area.enable_hero_card_visibility(true)


	return outcome


func _effect_text() -> String:
	return "Reveal the hero's card"
