@tool
class_name RevealHero
extends Effect



func requests_hero_card_reveal() -> bool:
	return true


func _effect_text() -> String:
	return "Reveal the hero's card"
