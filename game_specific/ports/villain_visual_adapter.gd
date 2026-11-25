class_name VillainVisualAdapter
extends VillainPort

const VILLAIN_SCENE: PackedScene = preload("uid://cs4gqthniprqk")

var _villain: Villain
var _villain_visuals: VillainVisuals
# var _combat_input: CombatInput

var _pending_choice: Choice = null
var _reset_requested: bool = false
var _spell_selection_active: bool = false

signal choice_submitted(choice: Choice)


func _init(
	villain: Villain,
	visual_parent: Node
) -> void:
	_villain = villain
	_villain.prepare()
	_villain_visuals = VILLAIN_SCENE.instantiate() as VillainVisuals
	_villain_visuals.prepare(_villain.deck, _villain)
	visual_parent.add_child(_villain_visuals)
	_villain_visuals.spell_chosen.connect(_on_spell_chosen)
	_villain_visuals.cards_selected.connect(_on_cards_selected)
	_villain_visuals._SpellConfirmBtn.pressed.connect(func(): submit_choice(EndChoice.new()))
	_villain_visuals.change_current_symbol(_villain.current_symbol)


func get_character() -> Villain:
	return _villain.create_state_copy()


func update_character(character: Character) -> void:
	assert(character is Villain, "VillainVisualAdapter can only update from Villain state.")
	var villain_state := character as Villain
	_villain.restore_villain_state_from(villain_state)
	await _synchronize_presentation()


func apply_effect(effect: Effect) -> void:
	if effect.apply(_villain):
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


func submit_choice(choice: Choice) -> void:
	_pending_choice = choice
	choice_submitted.emit(choice)


func await_choice() -> Choice:
	if _pending_choice == null:
		await choice_submitted
	var choice: Choice = _pending_choice
	_pending_choice = null
	return choice


func request_reset() -> void:
	_reset_requested = true
	submit_choice(ResetChoice.new())


func cancel_active_wait() -> void:
	request_reset()
	_villain_visuals.cancel_selection()


func _on_spell_chosen(spell: VillainSpell) -> void:
	var sc: SpellChoice = SpellChoice.new()
	sc.spell = spell
	submit_choice(sc)


func _on_cards_selected(cards: Array[CardData]) -> void:
	var cc := CardsChoice.new()
	cc.cards = cards
	submit_choice(cc)


func _end_spell_selection() -> void:
	_spell_selection_active = false
	_villain_visuals.end_spell_selection()


func choose_spell() -> VillainSpell:
	if not _spell_selection_active:
		_spell_selection_active = true
		_villain_visuals.begin_spell_selection()
	while true:
		if _reset_requested:
			_end_spell_selection()
			_reset_requested = false
			return null
		_villain_visuals.resume_spell_selection()
		var choice: Choice = await await_choice()
		if choice is SpellChoice:
			var spell_choice: SpellChoice = choice as SpellChoice
			_villain_visuals.pause_spell_selection()
			return spell_choice.spell
		_end_spell_selection()
		_reset_requested = choice is ResetChoice
		return null
	return null


func cast_spell(spell: VillainSpell) -> Array[Effect]:
	_villain.spend_mana(spell.mana_cost)
	_villain_visuals.refresh_stats()
	_villain_visuals.refresh_spell_availability()
	return spell.effects







func play_card() -> VillainCardData:
	_villain_visuals.begin_card_selection()
	var choice: Choice = await await_choice()
	_villain_visuals._finish_card_choice()
	var card: CardData = null
	if choice is CardsChoice:
		var cards: Array[CardData] = (choice as CardsChoice).cards
		if cards.size() > 0:
			card = cards[0]
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
	_villain_visuals.begin_card_selection(amount)
	var choice: Choice = await await_choice()
	_villain_visuals._finish_card_choice()
	var picked: Array[CardData] = []
	if choice is CardsChoice:
		picked.assign((choice as CardsChoice).cards)
	return picked


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
	_villain_visuals.refresh_stats()
	await _synchronize_hand_and_stats()
	_villain_visuals.change_current_symbol(_villain.current_symbol)


func _synchronize_hand_and_stats() -> void:
	await _villain_visuals.restore_hand(_villain.deck.display_hand())
