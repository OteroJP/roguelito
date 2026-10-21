class_name CombatManager extends RefCounted

# refactor:
# CombatPort.
# VisualCombatAdapter and HeadlessCombatAdapter

#region State and reset snapshots
# Keep each combatant's port instance stable for this combat; state is keyed by port identity.
var _combatant_states: Dictionary[CharacterPort, CombatantState] = {}
var _hero_port: HeroPort
var _villain_port: VillainPort
var _playing_area: PlayingArea
# Selected cards are cycle decisions and are intentionally excluded from state copies.
var _selected_hero_card: HeroCardData
var _selected_villain_card: VillainCardData
var _hero_card_enabled: bool = true
var _villain_card_enabled: bool = true


func _init(
	hero_port: HeroPort,
	villain_port: VillainPort,
	playing_area: PlayingArea
) -> void:
	_hero_port = hero_port
	_villain_port = villain_port
	_playing_area = playing_area
	_combatant_states[hero_port] = CombatantState.new()
	_combatant_states[villain_port] = CombatantState.new()


func create_state_copy() -> CombatManager:
	var copy := CombatManager.new(_hero_port, _villain_port, _playing_area)
	copy._combatant_states[_hero_port] = _combatant_states[_hero_port].create_state_copy()
	copy._combatant_states[_villain_port] = _combatant_states[_villain_port].create_state_copy()
	return copy


func restore_state_from(source: CombatManager) -> void:
	assert(source != self, "Cannot restore CombatManager state from itself.")
	assert(
		source._hero_port == _hero_port and source._villain_port == _villain_port,
		"CombatManager state belongs to different character ports."
	)
	_combatant_states[_hero_port] = source._combatant_states[_hero_port].create_state_copy()
	_combatant_states[_villain_port] = source._combatant_states[_villain_port].create_state_copy()
	clear_selected_cards()


#endregion

#region Card selection
func set_selected_hero_card(card: HeroCardData) -> void:
	_selected_hero_card = card


func set_selected_villain_card(card: VillainCardData) -> void:
	_selected_villain_card = card


func cancel_hero_card() -> void:
	_hero_card_enabled = false
	sync_card_enabled_state()


func cancel_villain_card() -> void:
	_villain_card_enabled = false
	sync_card_enabled_state()


func clear_selected_cards() -> void:
	_selected_hero_card = null
	_selected_villain_card = null
	_hero_card_enabled = true
	_villain_card_enabled = true
	sync_card_enabled_state()


func selected_villain_card() -> VillainCardData:
	return _selected_villain_card


#endregion

#region Card presentation
func present_selected_card(card: CardData, face_up: bool = false) -> void:
	await _playing_area.add_card(card, face_up)
	sync_card_enabled_state()


func reveal_hero_card() -> void:
	if _selected_hero_card != null:
		_playing_area.reveal_card(_selected_hero_card)


func reveal_cards() -> Array[CardData]:
	assert(
		_selected_hero_card != null and _selected_villain_card != null,
		"Both selected cards are required before resolution."
	)
	_playing_area.reveal_cards()
	await _playing_area.get_tree().process_frame
	return _cards_by_speed()


func discard_presented_card(card: CardData) -> void:
	_playing_area.discard_card(card)


func sync_card_enabled_state() -> void:
	# PlayingArea slots follow presentation order: Hero first, then Villain.
	var enabled_by_slot: Array[bool] = [_hero_card_enabled, _villain_card_enabled]
	_playing_area.set_card_slots_enabled(enabled_by_slot)


func clear_resolution_display() -> void:
	await _playing_area.get_tree().create_timer(GameManager.ux_delay).timeout
	await _playing_area.clear()
	sync_card_enabled_state()


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
		var target_port := _target_port_for(effect_owner, execution_effect)
		if execution_effect is AttackEffect:
			var attack_effect := execution_effect as AttackEffect
			var attack := attack_effect.build_attack(_create_combat_context())
			_apply_attack_modifiers(effect_owner, attack)
			await target_port.take_attack(attack)
		else:
			await target_port.apply_effect(execution_effect)


func run_effect_batch(
	configured_effects: Array[Effect],
	effect_owner: CharacterPort
) -> void:
	var execution_effects := effect_owner.create_effect_copies(configured_effects)
	await run_effect_copies(execution_effects, effect_owner)


func _target_port_for(effect_owner: CharacterPort, effect: Effect) -> CharacterPort:
	assert(
		effect_owner == _hero_port or effect_owner == _villain_port,
		"Effect owner must be one of the combatant ports."
	)
	if effect.target_side == Effect.TargetSide.OWNER:
		return effect_owner
	if effect_owner == _hero_port:
		return _villain_port
	return _hero_port


func _create_combat_context() -> CombatContext:
	return CombatContext.new(
		_hero_port.get_character(),
		_villain_port.get_character()
	)


func resolve_card(card: CardData) -> void:
	if _card_is_enabled(card):
		await _playing_area.resolve_card(card)
		await _resolve_card_effects(card)

	sync_card_enabled_state()
	await _playing_area.get_tree().create_timer(GameManager.ux_delay).timeout


# part of subsystem that would be inside the port
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


func _card_is_enabled(card: CardData) -> bool:
	if card is HeroCardData:
		return _hero_card_enabled
	return _villain_card_enabled


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
	for status: Status in active_statuses:
		if not _combatant_states[combatant_port].statuses.has(status):
			continue
		await run_effect_batch(status.status_effects, combatant_port)
		if status.advance_duration():
			remove_status(combatant_port, status)


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


# is this necesary? Because I think it shouldn't exist... round?
func clear_round_modifiers() -> void:
	_clear_round_modifiers_for(_hero_port)
	_clear_round_modifiers_for(_villain_port)


func _clear_round_modifiers_for(combatant_port: CharacterPort) -> void:
	var state := _combatant_states[combatant_port]
	clear_speed_bonus(combatant_port)
	for modifier: AttackModifier in state.attack_modifiers.duplicate():
		if modifier.spend_use():
			remove_attack_modifier(combatant_port, modifier)
	sync_combat_indicators(combatant_port)


#endregion

#region Attack execution
func _apply_attack_modifiers(attacker_port: CharacterPort, attack: Attack) -> void:
	for modifier: AttackModifier in attack_modifiers_for(attacker_port):
		modifier.modify_attack(attack)

#endregion


class CombatContext:
	extends RefCounted

	## Both values are character copies supplied by their ports, for read-only calculations.
	var hero: Hero
	var villain: Villain


	func _init(hero_copy: Hero, villain_copy: Villain) -> void:
		hero = hero_copy
		villain = villain_copy


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
