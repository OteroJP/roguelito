@tool
class_name VillainTakeStatus
extends Effect

@export var status: Status

func on_clash(villain: Villain, hero: Hero):
	villain.take_status(status)


func _effect_text() -> String:
	var duration_text := "ever" if status.duration == -1 else ("%s ticks" % str(status.duration))
	return "Villain takes a %s status (%s for %s)." % [status.name, status.effect_text, str(status.duration)]
