@tool
class_name VillainCardData
extends CardData

@export var symbol_to_complete: Villain.Symbol
@export var symbol_to_spawn: Villain.Symbol


func on_play(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	villain.symbol_completed.emit(symbol_to_complete)
	if symbol_to_complete == Villain.Symbol.NONE or villain.current_symbol != symbol_to_complete:
		return outcome
	for symbol_bonus: SymbolBonus in villain.symbol_bonuses:
		if symbol_bonus.symbol != symbol_to_complete:
			continue
		outcome.add(
			AuditEvent.Kind.SYMBOL_BONUS_RESOLVED,
			AuditLogEntry.Source.VILLAIN,
			0,
			Villain.Symbol.keys()[symbol_to_complete]
		)
		for bonus: Effect in symbol_bonus.bonuses:
			outcome.append(await bonus.on_clash(villain, hero))
	villain.symbol_count[symbol_to_complete] += 1
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
	villain.current_symbol = symbol_to_spawn
	resolved.emit(self)
	return AuditOutcome.new()


func on_discard(villain: Villain, hero: Hero) -> AuditOutcome:
	return AuditOutcome.new()


func _bonus_color() -> Color:
	return UIAssets.VILLAIN_SECOND_PHASE_COLOR
