@tool
class_name CancelSelectedCard
extends Effect



func combat_state_changes(_effect_owner: Character) -> Array[CombatStateChange]:
	var change := CombatStateChange.new(target_side)
	change.cancel_card = true
	return [change]


func _effect_text() -> String:
	return "Cancel the %s's card" % target_label()
