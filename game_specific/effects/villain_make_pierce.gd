@tool
class_name VillainPierce
extends Effect



func combat_state_changes(_effect_owner: Character) -> Array[CombatStateChange]:
	var change := CombatStateChange.new(target_side)
	change.modifiers_to_add.append(PierceModifier.new())
	return [change]


func _effect_text() -> String:
	return "Villain's attacks ignore armor"
