@tool
class_name VillainCardData
extends CardData

@export var symbol_to_complete: Villain.Symbol
@export var symbol_to_spawn: Villain.Symbol


func on_play(
	villain: Villain,
	hero: Hero,
	villain_port: VillainPort,
	hero_port: HeroPort,
	combat_manager: CombatManager
) -> AuditOutcome:
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
		outcome.append(
			await combat_manager.run_effect_batch(symbol_bonus.bonuses, villain_port, hero_port)
		)
	villain.symbol_count[symbol_to_complete] += 1
	return outcome


func on_clash(
	villain: Villain,
	hero: Hero,
	villain_port: VillainPort,
	hero_port: HeroPort,
	combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if villain.is_in_second_phase():
		outcome.add(AuditEvent.Kind.SECOND_PHASE_BONUS_TRIGGERED, AuditLogEntry.Source.VILLAIN)
		outcome.append(await combat_manager.run_effect_batch(bonus_effects, villain_port, hero_port))
	outcome.append(await combat_manager.run_effect_batch(effects, villain_port, hero_port))
	return outcome


func after_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	villain.current_symbol = symbol_to_spawn
	resolved.emit(self)
	return AuditOutcome.new()


func on_discard(villain: Villain, hero: Hero) -> AuditOutcome:
	return AuditOutcome.new()


func _bonus_color() -> Color:
	return UIAssets.VILLAIN_SECOND_PHASE_COLOR
