@tool
class_name VillainAttackArmor
extends Effect

@export var multiplier: int = 1
@export var bonus_multiplier: int = 2
@export var ignores_armor: bool = false

var _attack_multiplier: int = 0


func prepare(effect_owner_port: CharacterPort) -> void:
	var villain := effect_owner_port.get_character() as Villain
	_attack_multiplier = bonus_multiplier if (villain != null and villain.is_in_second_phase()) else multiplier


func build_attack(_owner: Character, target: Character) -> Attack:
	var hero := target as Hero
	assert(hero != null, "VillainAttackArmor needs a Hero target.")
	return Attack.new(hero.max_armor * _attack_multiplier, ignores_armor)


func _effect_text() -> String:
	var amount := "the hero's max armor" if multiplier == 1 else (
		"%d times the hero's max armor" % multiplier
	)
	var bonus_amount := "the hero's max armor" if bonus_multiplier == 1 else (
		"%d times the hero's max armor" % bonus_multiplier
	)
	var bonus_text := (
		"[color=#%s](%s if in second phase)[/color]"
		% [UIAssets.VILLAIN_SECOND_PHASE_COLOR, bonus_amount]
	)
	var text := "Villain attacks for %s as damage %s" % [amount, bonus_text]
	if ignores_armor:
		text += ", ignoring armor"
	return text
