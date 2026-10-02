@tool
class_name HeroTakesDamage
extends Effect


@export var damage: int
@export var ignores_armor: bool = false

func on_clash(villain: Villain, hero: Hero):
	hero.take_damage(damage, ignores_armor)


func _effect_text() -> String:
	var text := "Hero takes %d damage" % damage
	if ignores_armor:
		text += ", ignoring armor"
	return text
