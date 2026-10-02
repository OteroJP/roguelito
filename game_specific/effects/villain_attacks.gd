@tool
class_name VillainAttack
extends Effect

@export var damage: int
@export var ignores_armor: bool = false

func on_clash(villain: Villain, hero: Hero):
	villain.perform_attack(hero, damage, ignores_armor)


func _effect_text() -> String:
	var text := "Villain attacks for %d damage" % damage
	if ignores_armor:
		text += ", ignoring armor"
	return text
