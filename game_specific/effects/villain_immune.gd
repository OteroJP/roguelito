@tool
class_name VillainImmune
extends Effect


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	villain.immune_to_damage = true


	return outcome


func _effect_text() -> String:
	return "Villain is immune to damage"
