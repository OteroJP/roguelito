@tool
class_name HeroAttacks
extends Effect

@export var damage: int
@export var ignores_armor: bool = false

func on_clash(villain: Villain, hero: Hero):
	hero.perform_attack(villain, damage, ignores_armor)


func _effect_text() -> String:
	var text := "Hero attacks for %d damage" % damage
	if ignores_armor:
		text += ", ignoring armor"
	return text
