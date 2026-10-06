@tool
class_name HeroArmors
extends Effect

@export var amount_to_armor: int

func on_clash(villain: Villain, hero: Hero):
	hero.set_armor(hero.armor + amount_to_armor)

func _effect_text() -> String:
	return "Hero gets %d armor" % amount_to_armor
