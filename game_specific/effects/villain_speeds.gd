@tool
class_name VillainSpeeds
extends Effect
## Increases should always be multiple of 2 so there are no ties

@export var speed_modification: int


func _on_clash(
	_villain: Villain,
	_hero: Hero,
	villain_port: VillainPort,
	_hero_port: HeroPort,
	combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	combat_manager.add_speed_bonus(villain_port, speed_modification)
	outcome.add(AuditEvent.Kind.BONUS_SPEED_CHANGED, AuditLogEntry.Source.VILLAIN, speed_modification)


	return outcome


func _clear_effect_data() -> void:
	pass


func _effect_text() -> String:
	if speed_modification < 0:
		return "Villain loses %d speed" % absi(speed_modification)
	return "Villain gains %d speed" % speed_modification
