@tool
class_name VillainTakeStatus
extends Effect

@export var status: Status


func _on_clash(
	_villain: Villain,
	_hero: Hero,
	villain_port: VillainPort,
	_hero_port: HeroPort,
	combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	combat_manager.add_status(villain_port, status)


	return outcome


func _effect_text() -> String:
	var duration_text := "ever" if status.duration == -1 else ("%s ticks" % str(status.duration))
	return "Villain takes a %s status (%s for %s)." % [status.name, status.effect_text, str(status.duration)]
