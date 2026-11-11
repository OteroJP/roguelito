@tool
class_name VillainHealSymbol
extends Effect

@export var symbol: Villain.Symbol = Villain.Symbol.NONE
@export var threshold: int = 1
@export var heal_under_threshold: int = 0
@export var heal_over_threshold: int = 1

var _amount: int = 0


func prepare(effect_owner_port: CharacterPort) -> void:
	var villain := effect_owner_port.get_character() as Villain
	_amount = heal_under_threshold if (villain != null and (symbol == Villain.Symbol.NONE or villain.symbol_count[symbol] < threshold)) else heal_over_threshold


func apply(target: Character) -> bool:
	var villain := target as Villain
	assert(villain != null, "VillainHealSymbol requires a Villain target.")
	var previous_health := villain.health
	var amount := _amount
	villain.heal(amount)
	return villain.health != previous_health


func _effect_text() -> String:
	return "Villain heals for %d if over %s %s, else for %s" % [
		heal_over_threshold,
		threshold,
		Villain.Symbol.keys()[symbol],
		heal_under_threshold
	]
