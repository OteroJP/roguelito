class_name CombatManager extends RefCounted

signal card_enabled_state_changed
signal hero_card_reveal_requested

#region State and reset snapshots
# Keep each combatant's port instance stable for this combat; state is keyed by port identity.
var _combatant_states: Dictionary[CharacterPort, CombatantState] = {}
var _hero_port: HeroPort
var _villain_port: VillainPort
# Selected cards are cycle decisions and are intentionally excluded from state copies.
var _selected_hero_card: HeroCardData
var _selected_villain_card: VillainCardData
var _hero_card_enabled: bool = true
var _villain_card_enabled: bool = true


func _init(
	hero_port: HeroPort,
	villain_port: VillainPort
) -> void:
	_hero_port = hero_port
	_villain_port = villain_port
	_combatant_states[hero_port as CharacterPort] = CombatantState.new()
	_combatant_states[villain_port as CharacterPort] = CombatantState.new()


func create_state_copy() -> CombatManager:
	var copy := CombatManager.new(_hero_port, _villain_port)
	copy._combatant_states[_hero_port as CharacterPort] = (
		_combatant_states[_hero_port as CharacterPort].create_state_copy()
	)
	copy._combatant_states[_villain_port as CharacterPort] = (
		_combatant_states[_villain_port as CharacterPort].create_state_copy()
	)
	return copy


func restore_state_from(source: CombatManager) -> void:
	assert(source != self, "Cannot restore CombatManager state from itself.")
	assert(
		source._hero_port == _hero_port and source._villain_port == _villain_port,
		"CombatManager state belongs to different character ports."
	)
	_combatant_states[_hero_port as CharacterPort] = (
		source._combatant_states[_hero_port as CharacterPort].create_state_copy()
	)
	_combatant_states[_villain_port as CharacterPort] = (
		source._combatant_states[_villain_port as CharacterPort].create_state_copy()
	)
	clear_selected_cards()
	sync_combat_indicators(_hero_port)
	sync_combat_indicators(_villain_port)


#endregion

#region Card selection
func set_selected_hero_card(card: HeroCardData) -> void:
	_selected_hero_card = card


func set_selected_villain_card(card: VillainCardData) -> void:
	_selected_villain_card = card


func cancel_hero_card() -> void:
	_hero_card_enabled = false
	card_enabled_state_changed.emit()


func cancel_villain_card() -> void:
	_villain_card_enabled = false
	card_enabled_state_changed.emit()


func clear_selected_cards() -> void:
	_selected_hero_card = null
	_selected_villain_card = null
	_hero_card_enabled = true
	_villain_card_enabled = true
	card_enabled_state_changed.emit()


func card_enabled_state() -> Array[bool]:
	return [_hero_card_enabled, _villain_card_enabled]


func card_is_enabled(card: CardData) -> bool:
	if card is HeroCardData:
		return _hero_card_enabled
	return _villain_card_enabled


func selected_villain_card() -> VillainCardData:
	return _selected_villain_card


func selected_hero_card() -> HeroCardData:
	return _selected_hero_card


func reveal_hero_card() -> void:
	hero_card_reveal_requested.emit()


func cards_in_resolution_order() -> Array[CardData]:
	assert(
		_selected_hero_card != null and _selected_villain_card != null,
		"Both selected cards are required before resolution."
	)
	return _cards_by_speed()


func _cards_by_speed() -> Array[CardData]:
	if (
		_selected_hero_card.speed + speed_bonus_for(_hero_port)
		> _selected_villain_card.speed + speed_bonus_for(_villain_port)
	):
		return [_selected_hero_card, _selected_villain_card]
	return [_selected_villain_card, _selected_hero_card]


#endregion

#region Card and effect resolution
func run_effect_copies(
	execution_effects: Array[Effect],
	effect_owner: CharacterPort
) -> void:
	for execution_effect: Effect in execution_effects:
		await effect_owner.prepare_effect(execution_effect)
		var target_port:CharacterPort = _target_port_for(effect_owner, execution_effect)

		if execution_effect.has_capability(Effect.Capability.CHARACTER_DATA):
			await target_port.apply_effect(execution_effect)

		if execution_effect.has_capability(Effect.Capability.COMBAT_STATE):
			var changes := execution_effect.combat_state_changes()
			_apply_combat_state_changes(changes, effect_owner)

		if execution_effect.has_capability(Effect.Capability.ATTACK_GENERATOR):
			var attack: Attack = execution_effect.build_attack(
				effect_owner.get_character(),
				target_port.get_character()
			)
			_apply_attack_modifiers(effect_owner, attack)
			await target_port.take_attack(attack)


func run_effect_batch(
	configured_effects: Array[Effect],
	effect_owner: CharacterPort
) -> void:
	var execution_effects := effect_owner.create_effect_copies(configured_effects)
	await run_effect_copies(execution_effects, effect_owner)


func _apply_combat_state_changes(
	changes: Array[CombatStateChange],
	effect_owner: CharacterPort
) -> void:
	for change: CombatStateChange in changes:
		var recipient_port := _port_for_relative_side(effect_owner, change.recipient)

		if change is CombatStateChange.AddStatus:
			add_status(recipient_port, change.status)
			sync_combat_indicators(recipient_port)
		elif change is CombatStateChange.RemoveStatuses:
			var removed_status := false
			for status: Status in statuses_for(recipient_port):
				if status.name == change.status_name:
					remove_status(recipient_port, status)
					removed_status = true
			if removed_status:
				sync_combat_indicators(recipient_port)
		elif change is CombatStateChange.AddSpeedBonus:
			add_speed_bonus(recipient_port, change.amount)
			sync_combat_indicators(recipient_port)
		elif change is CombatStateChange.ClearSpeedBonus:
			clear_speed_bonus(recipient_port)
			sync_combat_indicators(recipient_port)
		elif change is CombatStateChange.AddAttackModifier:
			add_attack_modifier(recipient_port, change.modifier)
			sync_combat_indicators(recipient_port)
		elif change is CombatStateChange.RemoveAttackModifier:
			if change.modifier in attack_modifiers_for(recipient_port):
				remove_attack_modifier(recipient_port, change.modifier)
				sync_combat_indicators(recipient_port)
		elif change is CombatStateChange.CancelSelectedCard:
			if recipient_port == _hero_port:
				cancel_hero_card()
			else:
				assert(recipient_port == _villain_port)
				cancel_villain_card()
		else:
			assert(false, "Unsupported combat state change: %s" % change.get_class())


func _target_port_for(effect_owner: CharacterPort, effect: Effect) -> CharacterPort:
	return _port_for_relative_side(effect_owner, effect.target_side)


func _port_for_relative_side(effect_owner: CharacterPort, side: int) -> CharacterPort:
	assert(
		effect_owner == _hero_port or effect_owner == _villain_port,
		"Effect owner must be one of the combatant ports."
	)
	if side == CombatStateChange.Recipient.OWNER:
		return effect_owner
	assert(side == CombatStateChange.Recipient.OPPONENT, "Unknown combatant side.")
	if effect_owner == _hero_port:
		return _villain_port
	return _hero_port


func resolve_card(card: CardData) -> void:
	if card_is_enabled(card):
		await _resolve_card_effects(card)


# Card-specific rule execution; presentation is handled by CombatPort adapters.
func _resolve_card_effects(card: CardData) -> void:
	if card is HeroCardData:
		var hero_card := card as HeroCardData
		var hero := _hero_port.get_character()
		if hero.is_in_stance(hero_card.stance_for_bonus):
			await _run_card_effect_batch(_hero_port, hero_card.bonus_effects)
		await _run_card_effect_batch(_hero_port, hero_card.effects)
	elif card is VillainCardData:
		var villain_card := card as VillainCardData
		var villain := _villain_port.get_character()
		if villain.is_in_second_phase():
			await _run_card_effect_batch(_villain_port, villain_card.bonus_effects)
		await _run_card_effect_batch(_villain_port, villain_card.effects)


func _run_card_effect_batch(
	owner_port: CharacterPort,
	configured_effects: Array[Effect]
) -> void:
	await run_effect_batch(configured_effects, owner_port)


#endregion

#region Combatant state and indicators
func sync_combat_indicators(combatant_port: CharacterPort) -> void:
	combatant_port.sync_combat_indicators(
		statuses_for(combatant_port),
		attack_modifiers_for(combatant_port),
		speed_bonus_for(combatant_port)
	)


func add_status(combatant_port: CharacterPort, status: Status) -> Status:
	var applied_status := status.duplicate(true) as Status
	_combatant_states[combatant_port].statuses.append(applied_status)
	return applied_status


# is this necesary?
func statuses_for(combatant_port: CharacterPort) -> Array[Status]:
	return _combatant_states[combatant_port].statuses.duplicate()


func remove_status(combatant_port: CharacterPort, status: Status) -> void:
	var statuses := _combatant_states[combatant_port].statuses
	if status not in statuses:
		return
	# could we erase the signal doing something here?
	statuses.erase(status)


func tick_statuses(combatant_port: CharacterPort) -> void:
	var active_statuses := statuses_for(combatant_port)
	var removed_status := false
	for status: Status in active_statuses:
		if not _combatant_states[combatant_port].statuses.has(status):
			continue
		await run_effect_batch(status.status_effects, combatant_port)
		if status.advance_duration():
			remove_status(combatant_port, status)
			removed_status = true
	if removed_status:
		sync_combat_indicators(combatant_port)


func add_attack_modifier(combatant_port: CharacterPort, modifier: AttackModifier) -> void:
	_combatant_states[combatant_port].attack_modifiers.append(modifier)


# is this necesary?
func attack_modifiers_for(combatant_port: CharacterPort) -> Array[AttackModifier]:
	return _combatant_states[combatant_port].attack_modifiers.duplicate()


func remove_attack_modifier(combatant_port: CharacterPort, modifier: AttackModifier) -> void:
	var modifiers := _combatant_states[combatant_port].attack_modifiers
	if modifier not in modifiers:
		return
	modifiers.erase(modifier)


func add_speed_bonus(combatant_port: CharacterPort, amount: int) -> void:
	_combatant_states[combatant_port].speed_bonus += amount


# is this necesary?
func speed_bonus_for(combatant_port: CharacterPort) -> int:
	return _combatant_states[combatant_port].speed_bonus


func clear_speed_bonus(combatant_port: CharacterPort) -> void:
	_combatant_states[combatant_port].speed_bonus = 0


func clear_speed_bonuses() -> void:
	for combatant_port: CharacterPort in _combatant_states:
		var state := _combatant_states[combatant_port]
		if state.speed_bonus == 0:
			continue
		state.speed_bonus = 0
		sync_combat_indicators(combatant_port)


#endregion

#region Attack execution
func _apply_attack_modifiers(attacker_port: CharacterPort, attack: Attack) -> void:
	var modifiers := attack_modifiers_for(attacker_port)
	if modifiers.is_empty():
		return

	for modifier: AttackModifier in modifiers:
		modifier.modify_attack(attack)
		if modifier.spend_use():
			remove_attack_modifier(attacker_port, modifier)
	sync_combat_indicators(attacker_port)

#endregion


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
