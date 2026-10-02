@tool
class_name SetHeroArmor
extends Effect

@export var new_armor: int

func on_clash(villain: Villain, hero: Hero):
	hero.set_armor(new_armor)


func _effect_text() -> String:
	return "Set hero armor to %d" % new_armor
