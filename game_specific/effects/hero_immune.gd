@tool
class_name HeroImmune
extends Effect

func on_clash(villain: Villain, hero: Hero):
	hero.immune_to_damage = true


func _effect_text() -> String:
	return "Hero is immune to damage"
