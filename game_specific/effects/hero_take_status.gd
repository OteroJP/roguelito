@tool
class_name HeroTakesStatus
extends Effect

@export var status: Status


func _on_clash(
	_villain: Villain,
	_hero: Hero,
	_villain_port: VillainPort,
	hero_port: HeroPort,
	combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var applied_status := combat_manager.add_status(hero_port, status)
	outcome.add(AuditEvent.Kind.STATUS_TAKEN, AuditLogEntry.Source.HERO, 0, applied_status.name)


	return outcome


func _effect_text() -> String:
	var duration_text := "ever" if status.duration == -1 else ("%s ticks" % str(status.duration))
	return "Hero takes a %s status (%s for %s)." % [status.name, status.effect_text, str(status.duration)]
