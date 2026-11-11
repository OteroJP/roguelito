@tool
class_name CharacterTakesStatus
extends Effect

@export var status: Status



func combat_state_changes(_effect_owner: Character) -> Array[CombatStateChange]:
	if status == null:
		return []
	var change := CombatStateChange.new(target_side)
	change.statuses_to_add.append(status)
	return [change]


func _effect_text() -> String:
	if status == null:
		return "%s takes a status" % target_label().capitalize()
	return "%s takes %s (%s)." % [
		target_label().capitalize(),
		status.name,
		status.effect_text
	]
