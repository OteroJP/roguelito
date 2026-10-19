@tool
class_name HeroSpeeds
extends Effect
## Increases should always be multiple of 2 so there are no ties

@export var speed_modification: int


func _on_clash(
	_villain: Villain,
	_hero: Hero,
	_villain_port: VillainPort,
	hero_port: HeroPort,
	combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	combat_manager.add_speed_bonus(hero_port, speed_modification)
	outcome.add(AuditEvent.Kind.BONUS_SPEED_CHANGED, AuditLogEntry.Source.HERO, speed_modification)


	return outcome


func _effect_text() -> String:
	if speed_modification < 0:
		return "Hero loses %d speed" % absi(speed_modification)
	return "Hero gains %d speed" % speed_modification
