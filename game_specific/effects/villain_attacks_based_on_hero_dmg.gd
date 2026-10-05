@tool
class_name VillainAttackHeroDamage
extends Effect

@export var ignores_armor: bool = false

var _hero_max_basic_damage: int = 0

func on_clash(villain: Villain, hero: Hero):
	_hero_max_basic_damage = hero.max_basic_damage
	villain.perform_attack(hero, hero.max_basic_damage, ignores_armor)


func _effect_text() -> String:
	var text := "Villain attacks for the hero's max damage (%s)" % _hero_max_basic_damage
	if ignores_armor:
		text += ", ignoring armor"
	return text
