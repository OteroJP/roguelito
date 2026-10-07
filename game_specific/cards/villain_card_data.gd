@tool
class_name VillainCardData
extends CardData

@export var symbol_to_complete: Villain.Symbol
@export var symbol_to_spawn: Villain.Symbol


func on_play(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	await villain.complete_symbol(symbol_to_complete)
	if villain.matches_current_symbol(symbol_to_complete):
		outcome.append(await villain.resolve_symbol_bonus())
	return outcome


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if villain.is_in_second_phase():
		outcome.add(AuditEvent.Kind.SECOND_PHASE_BONUS_TRIGGERED, AuditLogEntry.Source.VILLAIN)
		for effect in bonus_effects:
			outcome.append(await effect.on_clash(villain, hero))
	for effect in effects:
		outcome.append(await effect.on_clash(villain, hero))
	return outcome


func after_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	villain.change_symbol(symbol_to_spawn)
	resolved.emit(self)
	return AuditOutcome.new()


func on_discard(villain: Villain, hero: Hero) -> AuditOutcome:
	return AuditOutcome.new()


func _bonus_color() -> Color:
	return UIAssets.VILLAIN_SECOND_PHASE_COLOR
