@tool
class_name VillainAttackSymbol
extends Effect

@export var ignores_armor: bool = false
@export var symbol: Villain.Symbol = Villain.Symbol.NONE
@export var threshold: int = 1
@export var damage_under_threshold: int = 0
@export var damage_over_threshold: int = 1

var _damage: int = 0


func prepare(effect_owner_port: CharacterPort) -> void:
	var villain := effect_owner_port.get_character() as Villain
	_damage = damage_under_threshold if (villain != null and (symbol == Villain.Symbol.NONE or villain.symbol_count[symbol] < threshold)) else damage_over_threshold


func build_attack(_owner: Character, _target: Character) -> Attack:
	return Attack.new(_damage, ignores_armor)


func _effect_text() -> String:
	var text := "Villain attacks for %d damage if over %s %s, else for %s" % [
		damage_over_threshold,
		threshold,
		Villain.Symbol.keys()[symbol],
		damage_under_threshold
	]
	if ignores_armor:
		text += ", ignoring armor"
	return text
