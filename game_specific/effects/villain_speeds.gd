@tool
class_name VillainSpeeds
extends Effect
## Increases should always be multiple of 2 so there are no ties

@export var speed_modification: int


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	outcome.append(villain.get_bonus_speed(speed_modification))


	return outcome


func _effect_text() -> String:
	if speed_modification < 0:
		return "Villain loses %d speed" % absi(speed_modification)
	return "Villain gains %d speed" % speed_modification
