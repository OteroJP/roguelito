@tool
class_name VillainTakeStatusIfSymbol
extends Effect

@export var status: Status
@export var symbol: Villain.Symbol = Villain.Symbol.NONE
@export var threshold: int = 1

var _applies: bool = false


func prepare(effect_owner_port: CharacterPort) -> void:
	_applies = false
	if status == null:
		return
	var villain := effect_owner_port.get_character() as Villain
	if villain == null or symbol == Villain.Symbol.NONE:
		return
	_applies = villain.symbol_count[symbol] >= threshold


func combat_state_changes(_effect_owner: Character) -> Array[CombatStateChange]:
	if status == null or not _applies:
		return []
	var change := CombatStateChange.new(target_side)
	change.statuses_to_add.append(status)
	return [change]


func _effect_text() -> String:
	if status == null:
		return "If Villain has enough symbols, they take a status"
	return "If Villain has at least %s %s, they take %s (%s)." % [
		threshold,
		Villain.Symbol.keys()[symbol],
		status.name,
		status.effect_text
	]
