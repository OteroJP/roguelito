class_name CombatManager extends RefCounted

signal card_enabled_state_changed
signal hero_card_reveal_requested(card: CardData)

#region State and reset snapshots
# Keep each combatant's port instance stable for this combat; state is keyed by port identity.
var _combatant_states: Dictionary[CharacterPort, CombatantState] = {}
var _hero_port: HeroPort
var _villain_port: VillainPort


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
		_get_state(_hero_port).create_state_copy()
	)
	copy._combatant_states[_villain_port as CharacterPort] = (
		_get_state(_villain_port).create_state_copy()
	)
	return copy


func restore_state_from(source: CombatManager) -> void:
	assert(source != self, "Cannot restore CombatManager state from itself.")
	assert(
		source._hero_port == _hero_port and source._villain_port == _villain_port,
		"CombatManager state belongs to different character ports."
	)
	_combatant_states[_hero_port as CharacterPort] = (
		source._get_state(_hero_port).create_state_copy()
	)
	_combatant_states[_villain_port as CharacterPort] = (
		source._get_state(_villain_port).create_state_copy()
	)
	clear_selected_cards()
	sync_combat_indicators(_hero_port)
	sync_combat_indicators(_villain_port)


#endregion

#region Card selection
func set_selected_card(combatant_port: CharacterPort, card: CardData) -> void:
	_get_state(combatant_port).selected_card = card


func cancel_card(combatant_port: CharacterPort) -> void:
	_get_state(combatant_port).card_enabled = false
	card_enabled_state_changed.emit()


func clear_selected_cards() -> void:
	for combatant_port: CharacterPort in _combatant_states:
		var state: CombatantState = _get_state(combatant_port)
		state.selected_card = null
		state.card_enabled = true
	card_enabled_state_changed.emit()


func card_enabled_state() -> Array[bool]:
	return [
		_get_state(_hero_port).card_enabled,
		_get_state(_villain_port).card_enabled
	]


func card_is_enabled(card: CardData) -> bool:
	return _get_state(_port_for_selected_card(card)).card_enabled


func selected_card(combatant_port: CharacterPort) -> CardData:
	return _get_state(combatant_port).selected_card


func reveal_hero_card() -> void:
	var hero_card := selected_card(_hero_port)
	if hero_card != null:
		hero_card_reveal_requested.emit(hero_card)


func cards_in_resolution_order() -> Array[CardData]:
	var hero_card := selected_card(_hero_port)
	var villain_card := selected_card(_villain_port)
	assert(
		hero_card != null and villain_card != null,
		"Both selected cards are required before resolution."
	)
	return _cards_by_speed(hero_card, villain_card)


func _cards_by_speed(hero_card: CardData, villain_card: CardData) -> Array[CardData]:
	if (
		hero_card.speed + speed_bonus_for(_hero_port)
		> villain_card.speed + speed_bonus_for(_villain_port)
	):
		return [hero_card, villain_card]
	return [villain_card, hero_card]


func _port_for_selected_card(card: CardData) -> CharacterPort:
	for combatant_port: CharacterPort in _combatant_states:
		if _get_state(combatant_port).selected_card == card:
			return combatant_port
	assert(false, "Card is not selected by either combatant.")
	return null


#endregion

#region Card and effect resolution
func run_effect_copies(
	execution_effects: Array[Effect],
	effect_owner: CharacterPort
) -> void:
	for execution_effect: Effect in execution_effects:
		await effect_owner.prepare_effect(execution_effect)
		if execution_effect.requests_hero_card_reveal():
			reveal_hero_card()
		var target_port:CharacterPort = _target_port_for(effect_owner, execution_effect)
		await target_port.apply_effect(execution_effect)
		var changes := execution_effect.combat_state_changes(
			effect_owner.get_character()
		)
		_apply_combat_state_changes(changes, effect_owner)

		var attack: Attack = execution_effect.build_attack(
			effect_owner.get_character(),
			target_port.get_character()
		)
		if attack != null:
			_apply_attack_modifiers(effect_owner, attack)
			await target_port.take_attack(attack)	


func run_effect_batch(
	configured_effects: Array[Effect],
	effect_owner: CharacterPort
) -> void:
	var execution_effects: Array[Effect] = []
	for effect: Effect in configured_effects:
		execution_effects.append(effect.duplicate() as Effect)
	await run_effect_copies(execution_effects, effect_owner)


func _apply_combat_state_changes(
	changes: Array[CombatStateChange],
	effect_owner: CharacterPort
) -> void:
	for change: CombatStateChange in changes:
		var recipient_port := _port_for_relative_side(effect_owner, change.recipient)
		var combat_state_changed := false

		for status: Status in change.statuses_to_add:
			add_status(recipient_port, status)
			combat_state_changed = true

		for status: Status in statuses_for(recipient_port):
			if status.name in change.statuses_to_remove:
				remove_status(recipient_port, status)
				combat_state_changed = true

		for modifier: AttackModifier in change.modifiers_to_add:
			add_attack_modifier(recipient_port, modifier)
			combat_state_changed = true

		for modifier: AttackModifier in change.modifiers_to_remove:
			if modifier in attack_modifiers_for(recipient_port):
				remove_attack_modifier(recipient_port, modifier)
				combat_state_changed = true

		if change.clear_speed_bonuses:
			if speed_bonus_for(recipient_port) != 0:
				clear_speed_bonus(recipient_port)
				combat_state_changed = true
		if change.speed_bonus_to_add != 0:
			add_speed_bonus(recipient_port, change.speed_bonus_to_add)
			combat_state_changed = true

		if change.cancel_card:
			cancel_card(recipient_port)

		if combat_state_changed:
			sync_combat_indicators(recipient_port)


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
		await _resolve_card_effects(_port_for_selected_card(card), card)


# Card-specific bonus eligibility lives on the card subtype; the manager runs effects.
func _resolve_card_effects(owner_port: CharacterPort, card: CardData) -> void:
	if card.bonus_condition_met(owner_port.get_character()):
		await _run_card_effect_batch(owner_port, card.bonus_effects)
	await _run_card_effect_batch(owner_port, card.effects)


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
	_get_state(combatant_port).statuses.append(applied_status)
	return applied_status


# is this necesary?
func statuses_for(combatant_port: CharacterPort) -> Array[Status]:
	return _get_state(combatant_port).statuses.duplicate()


func remove_status(combatant_port: CharacterPort, status: Status) -> void:
	var statuses := _get_state(combatant_port).statuses
	if status not in statuses:
		return
	# could we erase the signal doing something here?
	statuses.erase(status)


func tick_statuses(combatant_port: CharacterPort) -> void:
	var active_statuses := statuses_for(combatant_port)
	var removed_status := false
	for status: Status in active_statuses:
		if not _get_state(combatant_port).statuses.has(status):
			continue
		await run_effect_batch(status.status_effects, combatant_port)
		if status.advance_duration():
			remove_status(combatant_port, status)
			removed_status = true
	if removed_status:
		sync_combat_indicators(combatant_port)


func add_attack_modifier(combatant_port: CharacterPort, modifier: AttackModifier) -> void:
	_get_state(combatant_port).attack_modifiers.append(modifier)


# is this necesary?
func attack_modifiers_for(combatant_port: CharacterPort) -> Array[AttackModifier]:
	return _get_state(combatant_port).attack_modifiers.duplicate()


func remove_attack_modifier(combatant_port: CharacterPort, modifier: AttackModifier) -> void:
	var modifiers := _get_state(combatant_port).attack_modifiers
	if modifier not in modifiers:
		return
	modifiers.erase(modifier)


func add_speed_bonus(combatant_port: CharacterPort, amount: int) -> void:
	_get_state(combatant_port).speed_bonus += amount


# is this necesary?
func speed_bonus_for(combatant_port: CharacterPort) -> int:
	return _get_state(combatant_port).speed_bonus


func clear_speed_bonus(combatant_port: CharacterPort) -> void:
	_get_state(combatant_port).speed_bonus = 0


func clear_speed_bonuses() -> void:
	for combatant_port: CharacterPort in _combatant_states:
		var state := _get_state(combatant_port)
		if state.speed_bonus == 0:
			continue
		state.speed_bonus = 0
		sync_combat_indicators(combatant_port)



func _get_state(combatant_port: CharacterPort) -> CombatantState:
	return _combatant_states[combatant_port]


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
	var selected_card: CardData
	var card_enabled: bool = true


	func create_state_copy() -> CombatantState:
		var copy := CombatantState.new()
		for status: Status in statuses:
			copy.statuses.append(status.duplicate(true) as Status)
		for modifier: AttackModifier in attack_modifiers:
			copy.attack_modifiers.append(modifier.create_state_copy())
		copy.speed_bonus = speed_bonus
		# Selected cards and their cancellation are cycle decisions, not restored state.
		return copy
