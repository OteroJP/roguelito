class_name CombatManager extends RefCounted


class CombatantState:
	extends RefCounted

	var statuses: Array[Status] = []
	var attack_modifiers: Array[AttackModifier] = []
	var speed_bonus: int = 0


	func create_state_copy() -> CombatantState:
		var copy := CombatantState.new()
		for status: Status in statuses:
			copy.statuses.append(status.duplicate(true) as Status)
		for modifier: AttackModifier in attack_modifiers:
			copy.attack_modifiers.append(modifier.create_state_copy())
		copy.speed_bonus = speed_bonus
		return copy


# Keep each combatant's port instance stable for this combat; state is keyed by port identity.
var _combatant_states: Dictionary[CharacterPort, CombatantState] = {}
var _hero_port: HeroPort
var _villain_port: VillainPort


func _init(hero_port: HeroPort, villain_port: VillainPort) -> void:
	_hero_port = hero_port
	_villain_port = villain_port
	_set_state(hero_port, CombatantState.new())
	_set_state(villain_port, CombatantState.new())


func create_state_copy() -> CombatManager:
	var copy := CombatManager.new(_hero_port, _villain_port)
	copy._set_state(_hero_port, _get_state(_hero_port).create_state_copy())
	copy._set_state(_villain_port, _get_state(_villain_port).create_state_copy())
	return copy


func restore_state_from(source: CombatManager) -> void:
	assert(source != self, "Cannot restore CombatManager state from itself.")
	assert(
		source._hero_port == _hero_port and source._villain_port == _villain_port,
		"CombatManager state belongs to different character ports."
	)
	_restore_combatant_state(_hero_port, source._get_state(_hero_port))
	_restore_combatant_state(_villain_port, source._get_state(_villain_port))


func _restore_combatant_state(
	combatant_port: CharacterPort,
	source_state: CombatantState
) -> void:
	var current_state := _get_state(combatant_port)
	for status: Status in current_state.statuses:
		_disconnect_status_depleted(status, combatant_port)
	for modifier: AttackModifier in current_state.attack_modifiers:
		_disconnect_attack_modifier_depleted(modifier, combatant_port)

	_combatant_states[combatant_port] = source_state.create_state_copy()
	var restored_state := _get_state(combatant_port)
	for status: Status in restored_state.statuses:
		_connect_status_depleted(status, combatant_port)
	for modifier: AttackModifier in restored_state.attack_modifiers:
		_connect_attack_modifier_depleted(modifier, combatant_port)


func run_effect_batch(
	effects: Array[Effect],
	villain_port: VillainPort,
	hero_port: HeroPort
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var execution_effects: Array[Effect] = []
	for configured_effect: Effect in effects:
		execution_effects.append(configured_effect.create_execution_copy())
	return await run_effect_copies(execution_effects, villain_port, hero_port)


func run_effect_copies(
	execution_effects: Array[Effect],
	villain_port: VillainPort,
	hero_port: HeroPort
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	for execution_effect: Effect in execution_effects:
		outcome.append(await execution_effect.on_clash(villain_port, hero_port, self))
	return outcome


func add_status(combatant_port: CharacterPort, status: Status) -> Status:
	var applied_status := status.duplicate(true) as Status
	_get_state(combatant_port).statuses.append(applied_status)
	_connect_status_depleted(applied_status, combatant_port)
	return applied_status


func statuses_for(combatant_port: CharacterPort) -> Array[Status]:
	return _get_state(combatant_port).statuses.duplicate()


func remove_status(combatant_port: CharacterPort, status: Status) -> void:
	var statuses := _get_state(combatant_port).statuses
	if status not in statuses:
		return
	statuses.erase(status)
	_disconnect_status_depleted(status, combatant_port)


func _connect_status_depleted(status: Status, combatant_port: CharacterPort) -> void:
	var callback := _on_status_depleted.bind(combatant_port)
	if not status.status_depleted.is_connected(callback):
		status.status_depleted.connect(callback)


func _disconnect_status_depleted(status: Status, combatant_port: CharacterPort) -> void:
	var callback := _on_status_depleted.bind(combatant_port)
	if status.status_depleted.is_connected(callback):
		status.status_depleted.disconnect(callback)


func tick_statuses(combatant_port: CharacterPort) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var active_statuses := statuses_for(combatant_port)
	for status: Status in active_statuses:
		if not _get_state(combatant_port).statuses.has(status):
			continue
		outcome.add(
			AuditEvent.Kind.STATUS_TICKED,
			_source_for(combatant_port),
			0,
			status.name
		)
		outcome.append(await run_effect_batch(status.status_effects, _villain_port, _hero_port))
		status.advance_duration()
	return outcome


func _on_status_depleted(status: Status, combatant_port: CharacterPort) -> void:
	remove_status(combatant_port, status)


func add_attack_modifier(combatant_port: CharacterPort, modifier: AttackModifier) -> void:
	var modifiers := _get_state(combatant_port).attack_modifiers
	modifiers.append(modifier)
	_connect_attack_modifier_depleted(modifier, combatant_port)


func attack_modifiers_for(combatant_port: CharacterPort) -> Array[AttackModifier]:
	return _get_state(combatant_port).attack_modifiers.duplicate()


func remove_attack_modifier(combatant_port: CharacterPort, modifier: AttackModifier) -> void:
	var modifiers := _get_state(combatant_port).attack_modifiers
	if modifier not in modifiers:
		return
	modifiers.erase(modifier)
	_disconnect_attack_modifier_depleted(modifier, combatant_port)


func _connect_attack_modifier_depleted(
	modifier: AttackModifier,
	combatant_port: CharacterPort
) -> void:
	var callback := _on_attack_modifier_depleted.bind(combatant_port)
	if not modifier.attack_modifier_depleted.is_connected(callback):
		modifier.attack_modifier_depleted.connect(callback)


func _disconnect_attack_modifier_depleted(
	modifier: AttackModifier,
	combatant_port: CharacterPort
) -> void:
	var callback := _on_attack_modifier_depleted.bind(combatant_port)
	if modifier.attack_modifier_depleted.is_connected(callback):
		modifier.attack_modifier_depleted.disconnect(callback)


func _on_attack_modifier_depleted(
	modifier: AttackModifier,
	combatant_port: CharacterPort
) -> void:
	remove_attack_modifier(combatant_port, modifier)


func add_speed_bonus(combatant_port: CharacterPort, amount: int) -> void:
	_get_state(combatant_port).speed_bonus += amount


func speed_bonus_for(combatant_port: CharacterPort) -> int:
	return _get_state(combatant_port).speed_bonus


func clear_speed_bonus(combatant_port: CharacterPort) -> void:
	_get_state(combatant_port).speed_bonus = 0


func clear_round_modifiers() -> void:
	_clear_round_modifiers_for(_hero_port)
	_clear_round_modifiers_for(_villain_port)


func _clear_round_modifiers_for(combatant_port: CharacterPort) -> void:
	var state := _get_state(combatant_port)
	clear_speed_bonus(combatant_port)
	for modifier: AttackModifier in state.attack_modifiers.duplicate():
		modifier.spend_use()



func perform_attack(
	attacker_port: CharacterPort,
	attacker: Character,
	target: Character,
	damage: int,
	ignores_armor: bool = false
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var attack := Attack.new(target, damage, ignores_armor)
	for modifier: AttackModifier in attack_modifiers_for(attacker_port):
		modifier.modify_attack(attack)
	outcome.add(
		AuditEvent.Kind.ATTACK,
		_source_for(attacker_port),
		damage,
		"",
		target.character_name,
		ignores_armor
	)
	outcome.append(target.take_attack(attack))
	return outcome


func _get_state(combatant_port: CharacterPort) -> CombatantState:
	assert(
		_combatant_states.has(combatant_port),
		"Combatant port was not registered at initialization."
	)
	return _combatant_states[combatant_port] as CombatantState


func _set_state(combatant_port: CharacterPort, state: CombatantState) -> void:
	_combatant_states[combatant_port] = state


func _source_for(character_port: CharacterPort) -> AuditLogEntry.Source:
	if character_port is HeroPort:
		return AuditLogEntry.Source.HERO
	if character_port is VillainPort:
		return AuditLogEntry.Source.VILLAIN
	assert(false, "Unknown combatant port.")
	return AuditLogEntry.Source.GAME
