@tool
class_name HeroRemoveStatus
extends Effect

@export var status_to_remove: Status



func combat_state_changes(_effect_owner: Character) -> Array[CombatStateChange]:
	if status_to_remove == null:
		return []
	var change := CombatStateChange.new(target_side)
	change.statuses_to_remove.append(status_to_remove.name)
	return [change]


func _effect_text() -> String:
    if status_to_remove == null:
        return "Hero removes a status"
    return "Hero removes all %s statuses" % status_to_remove.name
