@tool
class_name VillainCardData
extends CardData

@export var symbol_to_complete: Villain.Symbol
@export var symbol_to_spawn: Villain.Symbol

func on_play(villain: Villain, hero: Hero):
	villain.complete_symbol(symbol_to_complete)
	if villain.matches_current_symbol(symbol_to_complete):
		villain.resolve_symbol_bonus()


func on_clash(villain: Villain, hero: Hero):
	if villain.is_in_second_phase():
		villain.audit_report.add("2nd Phase bonus effects triggered!:", AuditLogEntry.Source.VILLAIN)
		for effect in bonus_effects:
			await effect.on_clash(villain, hero)
	for effect in effects:
		await effect.on_clash(villain, hero)


func after_clash(villain: Villain, hero: Hero):
	villain.change_symbol(symbol_to_spawn)
	resolved.emit(self)
	
	
func on_discard(villain: Villain, hero: Hero):
	pass


func _bonus_color() -> Color:
	return UIAssets.VILLAIN_SECOND_PHASE_COLOR
