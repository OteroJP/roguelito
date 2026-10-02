@tool
class_name VillainPierce
extends Effect

func on_clash(villain: Villain, hero: Hero):
	var pierce_modifier: PierceModifier = PierceModifier.new()
	villain.take_attack_modifier(pierce_modifier)


func _effect_text() -> String:
	return "Villain's attacks ignore armor"
