@tool
class_name RevealHero
extends Effect

func on_clash(villain: Villain, hero: Hero):
	GameManager.playing_area.enable_hero_card_visibility(true)


func _effect_text() -> String:
	return "Reveal the hero's card"
