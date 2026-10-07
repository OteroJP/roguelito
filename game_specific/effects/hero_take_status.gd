@tool
class_name HeroTakesStatus
extends Effect

@export var status: Status


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	outcome.append(await hero.take_status(status))


	return outcome


func _effect_text() -> String:
	var duration_text := "ever" if status.duration == -1 else ("%s ticks" % str(status.duration))
	return "Hero takes a %s status (%s for %s)." % [status.name, status.effect_text, str(status.duration)]
