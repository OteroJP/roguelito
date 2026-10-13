class_name CombatManager extends RefCounted


class CombatantState:
	extends RefCounted

	var statuses: Array[Status] = []
	var attack_modifiers: Array[AttackModifier] = []
	var speed_bonus: int = 0


var _combatant_states: Dictionary[Character, CombatantState] = {}


func run_effect_batch(
	effects: Array[Effect],
	villain_port: VillainPort,
	hero_port: HeroPort
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	for effect: Effect in effects:
		outcome.append(await effect.on_clash(villain_port, hero_port, self))
	return outcome


func add_status(character: Character, status: Status) -> Status:
	var applied_status := status.duplicate(true) as Status
	_get_or_create_state(character).statuses.append(applied_status)
	return applied_status


func statuses_for(character: Character) -> Array[Status]:
	return _get_or_create_state(character).statuses.duplicate()


func remove_status(character: Character, status: Status) -> void:
	_get_or_create_state(character).statuses.erase(status)


func add_attack_modifier(character: Character, modifier: AttackModifier) -> void:
	_get_or_create_state(character).attack_modifiers.append(modifier)


func attack_modifiers_for(character: Character) -> Array[AttackModifier]:
	return _get_or_create_state(character).attack_modifiers.duplicate()


func remove_attack_modifier(character: Character, modifier: AttackModifier) -> void:
	_get_or_create_state(character).attack_modifiers.erase(modifier)


func add_speed_bonus(character: Character, amount: int) -> void:
	_get_or_create_state(character).speed_bonus += amount


func speed_bonus_for(character: Character) -> int:
	return _get_or_create_state(character).speed_bonus


func clear_speed_bonus(character: Character) -> void:
	_get_or_create_state(character).speed_bonus = 0


func _get_or_create_state(character: Character) -> CombatantState:
	if not _combatant_states.has(character):
		_combatant_states[character] = CombatantState.new()
	return _combatant_states[character] as CombatantState
