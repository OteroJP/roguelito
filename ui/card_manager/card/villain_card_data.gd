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
		GameManager.add_log("2nd PHASE BONUS EFFECT:")
		for effect in bonus_effects:
			effect.on_clash(villain, hero)
	GameManager.add_log("REGULAR EFFECT:")
	for effect in effects:
		effect.on_clash(villain, hero)


func after_clash(villain: Villain, hero: Hero):
	villain.change_symbol(symbol_to_spawn)
	resolved.emit(self)
	
	
func on_discard(villain: Villain, hero: Hero):
	pass
