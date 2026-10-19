@tool
class_name VillainTakeStatusIfSymbol
extends Effect

@export var status: Status
@export var symbol: Villain.Symbol = Villain.Symbol.NONE
@export var threshold: int = 1


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
	var duration_text := "ever" if status.duration == -1 else ("%s ticks" % status.duration)
	return "If Villain has at least %s %s, they take a %d status (%s for %s)." % [threshold, str(symbol), status.name, status.effect_text, status.duration]
