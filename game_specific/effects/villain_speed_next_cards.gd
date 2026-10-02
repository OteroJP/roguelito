@tool
class_name VillainSpeedNext
extends Effect

func on_clash(villain: Villain, hero: Hero):
	var speed_modifier_status: PierceModifier = PierceModifier.new()
	villain.take_attack_modifier(pierce_modifier)


func _effect_text() -> String:
	return "Villain's attacks ignore armor"
