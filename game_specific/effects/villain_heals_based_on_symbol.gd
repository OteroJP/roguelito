@tool
class_name VillainHealSymbol
extends Effect

@export var symbol: Villain.Symbol = Villain.Symbol.NONE
@export var threshold: int = 1
@export var heal_under_threshold: int = 0
@export var heal_over_threshold: int = 1


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if (symbol == Villain.Symbol.NONE or
	villain.symbol_count[symbol] < threshold):
		outcome.append(villain.heal(heal_under_threshold))
	else:
		outcome.append(villain.heal(heal_over_threshold))


	return outcome


func _effect_text() -> String:
	var text := "Villain heals for %d if over %s %s, else for %s" % [heal_over_threshold, threshold, [Villain.Symbol.keys()[symbol]], heal_under_threshold]
	return text
