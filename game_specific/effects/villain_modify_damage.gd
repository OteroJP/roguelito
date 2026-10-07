@tool
class_name VillainModifyDamage
extends Effect

@export var damage_modification: int = 1


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var damage_modifier: DamageModifier = DamageModifier.new(1, damage_modification)
	outcome.append(villain.take_attack_modifier(damage_modifier))


	return outcome


func _effect_text() -> String:
	if damage_modification < 0:
		return "Villain's attacks deal %d less damage" % absi(damage_modification)
	return "Villain's attacks deal %d more damage" % damage_modification
