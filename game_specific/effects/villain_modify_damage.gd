@tool
class_name VillainModifyDamage
extends Effect

@export var damage_modification: int = 1



func combat_state_changes(_effect_owner: Character) -> Array[CombatStateChange]:
	var change := CombatStateChange.new(target_side)
    var modifier := DamageModifier.new(1, damage_modification)
	change.modifiers_to_add.append(modifier)
	return [change]


func _effect_text() -> String:
    if damage_modification < 0:
        return "Villain's attacks deal %d less damage" % absi(damage_modification)
    return "Villain's attacks deal %d more damage" % damage_modification
