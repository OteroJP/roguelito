class_name VillainVisualAdapter
extends VillainPort

const VILLAIN_SCENE: PackedScene = preload("uid://cs4gqthniprqk")

var _villain: Villain
var _villain_visuals: VillainVisuals
# var _combat_input: CombatInput
var _pending_spells: Array[VillainSpell] = []
var _spell_selection_complete: bool = false


func _init(
	villain: Villain,
	visual_parent: Node
) -> void:
	_villain = villain
	_villain.prepare()
	_villain_visuals = VILLAIN_SCENE.instantiate() as VillainVisuals
	_villain_visuals.prepare(_villain.deck, _villain)
	# _villain_visuals.set_combat_input(combat_input)
	# _villain_visuals.spell_chosen.connect(_on_spell_chosen)
	visual_parent.add_child(_villain_visuals)
	_villain_visuals.change_current_symbol(_villain.current_symbol)


func get_character() -> Villain:
	return _villain.create_state_copy()


func update_character(character: Character) -> void:
	assert(character is Villain, "VillainVisualAdapter can only update from Villain state.")
	var villain_state := character as Villain
	_villain.restore_villain_state_from(villain_state)
	await _synchronize_presentation()


func apply_effect(effect: Effect) -> void:
	effect.apply(_villain)
	await _synchronize_presentation()


func clear_immunity() -> void:
	_villain.clear_immunity()


func discard_played_card(card: CardData) -> void:
	_villain.deck.discard_played_card(card)


func set_current_symbol(symbol: Villain.Symbol) -> void:
	_villain.current_symbol = symbol
	_villain_visuals.change_current_symbol(symbol)


func sync_combat_indicators(
	statuses: Array[Status],
	attack_modifiers: Array[AttackModifier],
	speed_bonus: int
) -> void:
	_villain_visuals.sync_combat_indicators(
		statuses,
		attack_modifiers,
		speed_bonus
	)


func draw() -> void:
	var previous_hand_size := _villain.deck.cards_in_hand()
	_villain.draw()
	var current_hand := _villain.deck.display_hand()
	_villain_visuals.refresh_stats()
	if current_hand.size() > previous_hand_size:
		var drawn_cards: Array[CardData] = [current_hand.back()]
		await _villain_visuals.add_to_hand(drawn_cards)


func begin_spell_selection() -> void:
	_spell_selection_complete = false
	_pending_spells.clear()
	_villain_visuals.begin_spell_selection()


func spells_chosen() -> bool:
	return _spell_selection_complete


func choose_spell() -> VillainSpell:
	# _villain_visuals.resume_spell_selection()
	# while true:
	#	var command: int = await _combat_input.wait_for_command()
	#	match command:
	#		CombatInput.Command.SPELL_CHOSEN:
	#			if not _pending_spells.is_empty():
	#				_villain_visuals.pause_spell_selection()
	#				return _pending_spells.pop_front()
	#		CombatInput.Command.CONFIRM:
	#			finish_spell_selection()
	#			return null
	#		CombatInput.Command.RESET:
	#			_villain_visuals.end_spell_selection()
	#			return null
	return null


func finish_spell_selection() -> void:
	_spell_selection_complete = true
	_villain_visuals.end_spell_selection()


func _on_spell_chosen(spell: VillainSpell) -> void:
	_villain.spend_mana(spell.mana_cost)
	_villain_visuals.refresh_stats()
	_villain_visuals.refresh_spell_availability()
	_pending_spells.append(spell)
	# _combat_input.submit_action(CombatInput.Command.SPELL_CHOSEN)


func play_card() -> VillainCardData:
	var card: CardData = await _villain_visuals.choose_card()
	if card == null:
		return null
	var villain_card := card as VillainCardData
	var matching_symbol_completed := (
		villain_card.symbol_to_complete != Villain.Symbol.NONE
		and villain_card.symbol_to_complete == _villain.current_symbol
	)
	_villain.deck.play(card)
	_villain_visuals.refresh_stats()
	await _villain_visuals.remove_from_hand(card)
	_villain_visuals.change_completed_symbol(villain_card.symbol_to_complete)
	await GameManager.get_tree().create_timer(GameManager.ux_delay).timeout
	await _synchronize_hand_and_stats()
	_villain_visuals.change_current_symbol(_villain.current_symbol)
	_villain_visuals.change_completed_symbol(villain_card.symbol_to_complete)
	if matching_symbol_completed:
		await GameManager.get_tree().create_timer(GameManager.ux_delay).timeout
	return villain_card


func choose_cards_from_hand(amount: int) -> Array[CardData]:
	return await _villain_visuals.choose_cards(amount)


func choose_cards_from_discard(cards: Array[CardData], amount: int) -> Array[CardData]:
	return await _villain_visuals.choose_cards_from_discard(cards, amount)


func discard_over_hand_limit() -> void:
	await discard_from_hand(_villain.deck.cards_over_hand_limit())
	await _synchronize_presentation()


func take_cards_from_discard(amount: int) -> void:
	var count := mini(maxi(amount, 0), _villain.deck.cards_in_discard())
	if count <= 0:
		return
	var cards: Array[CardData] = await choose_cards_from_discard(
		_villain.deck.display_discard_pile(), count
	)
	_villain.take_cards_from_discard(cards)
	_villain_visuals.refresh_stats()
	if not cards.is_empty():
		await _villain_visuals.add_to_hand(cards)


func discard_from_hand(amount: int) -> void:
	var count := mini(maxi(amount, 0), _villain.deck.cards_in_hand())
	if count <= 0:
		return
	var cards: Array[CardData] = await choose_cards_from_hand(count)
	_villain.discard_from_hand(cards)
	_villain_visuals.refresh_stats()
	for card: CardData in cards:
		_villain_visuals.remove_from_hand(card)


func prepare_for_combat() -> void:
	await _villain_visuals.add_to_hand(_villain.deck.display_hand())
	_villain_visuals.refresh_stats()


func _synchronize_presentation() -> void:
	await _synchronize_hand_and_stats()
	_villain_visuals.change_current_symbol(_villain.current_symbol)


func _synchronize_hand_and_stats() -> void:
	await _villain_visuals.restore_hand(_villain.deck.display_hand())
