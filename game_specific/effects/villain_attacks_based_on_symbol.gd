@tool
class_name VillainAttackSymbol
extends Effect

@export var ignores_armor: bool = false
@export var symbol: Villain.Symbol = Villain.Symbol.NONE
@export var threshold: int = 1
@export var damage_under_threshold: int = 0
@export var damage_over_threshold: int = 1


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if (symbol == Villain.Symbol.NONE or
	villain.symbol_count[symbol] < threshold):
		outcome.append(villain.perform_attack(hero, damage_under_threshold, ignores_armor))
	else:
		outcome.append(villain.perform_attack(hero, damage_over_threshold, ignores_armor))


	return outcome


func _effect_text() -> String:
	var text := "Villain attacks for %d damage if over %s %s, else for %s" % [damage_over_threshold, threshold, Villain.Symbol.keys()[symbol], damage_under_threshold]
	if ignores_armor:
		text += ", ignoring armor"
	return text
