@tool
class_name VillainPierce
extends Effect


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var pierce_modifier: PierceModifier = PierceModifier.new()
	outcome.append(villain.take_attack_modifier(pierce_modifier))


	return outcome


func _effect_text() -> String:
	return "Villain's attacks ignore armor"
