@tool
class_name VillainImmune
extends Effect

func on_clash(villain: Villain, hero: Hero):
	villain.immune_to_damage = true


func _effect_text() -> String:
	return "Villain is immune to damage"
