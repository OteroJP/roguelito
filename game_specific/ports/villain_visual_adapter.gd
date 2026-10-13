class_name VillainVisualAdapter
extends VillainPort

signal interaction_logged(entry: AuditLogEntry)

const VILLAIN_SCENE: PackedScene = preload("uid://cs4gqthniprqk")

var _villain: Villain
var _villain_visuals: VillainVisuals


func _init(villain: Villain, visual_parent: Node, combat_input: CombatInput) -> void:
	_villain = villain
	_villain.prepare()
	_villain_visuals = VILLAIN_SCENE.instantiate() as VillainVisuals
	_villain_visuals.prepare(_villain.deck, _villain)
	_villain.current_symbol_changed.connect(_on_current_symbol_changed)
	_villain.symbol_completed.connect(_on_symbol_completed)
	_villain_visuals.set_combat_input(combat_input)
	_villain_visuals.interaction_logged.connect(_forward_interaction_logged)
	visual_parent.add_child(_villain_visuals)
	_villain_visuals.change_current_symbol(_villain.current_symbol)


func get_character() -> Villain:
	return _villain.create_state_copy()


func update_character(character: Villain) -> void:
	_villain.restore_villain_state_from(character)
	await _synchronize_presentation()


func draw() -> AuditOutcome:
	var previous_hand_size := _villain.deck.cards_in_hand()
	var outcome: AuditOutcome = await _villain.draw()
	var current_hand := _villain.deck.display_hand()
	_villain_visuals.refresh_stats()
	if current_hand.size() > previous_hand_size:
		var drawn_cards: Array[CardData] = [current_hand.back()]
		await _villain_visuals.add_to_hand(drawn_cards)
	return outcome


func cast_spells() -> AuditOutcome:
	var outcome: AuditOutcome = await _villain_visuals.cast_spells()
	await _synchronize_hand_and_stats()
	return outcome


func play_card() -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var card: CardData = await _villain_visuals.choose_card()
	if card == null:
		return outcome
	var villain_card := card as VillainCardData
	var matching_symbol_completed := (
		villain_card.symbol_to_complete != Villain.Symbol.NONE
		and villain_card.symbol_to_complete == _villain.current_symbol
	)
	_villain.deck.play(card)
	_villain_visuals.refresh_stats()
	await _villain_visuals.remove_from_hand(card)
	outcome.append(await GameManager.play_villain_card(card))
	await _synchronize_hand_and_stats()
	if matching_symbol_completed:
		await GameManager.get_tree().create_timer(GameManager.ux_delay).timeout
	outcome.add(AuditEvent.Kind.CARD_PLAYED, AuditLogEntry.Source.VILLAIN, 0, card.name)
	return outcome


func choose_cards_from_hand(amount: int) -> Array[CardData]:
	return await _villain_visuals.choose_cards(amount)


func choose_cards_from_discard(cards: Array[CardData], amount: int) -> Array[CardData]:
	return await _villain_visuals.choose_cards_from_discard(cards, amount)


func end_phase() -> AuditOutcome:
	var outcome: AuditOutcome = await discard_from_hand(_villain.deck.cards_over_hand_limit())
	await _synchronize_presentation()
	return outcome


func take_cards_from_discard(amount: int) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var count := mini(maxi(amount, 0), _villain.deck.cards_in_discard())
	if count <= 0:
		return outcome
	var cards: Array[CardData] = await choose_cards_from_discard(
		_villain.deck.display_discard_pile(), count
	)
	outcome.append(_villain.take_cards_from_discard(cards))
	_villain_visuals.refresh_stats()
	if not cards.is_empty():
		await _villain_visuals.add_to_hand(cards)
	return outcome


func discard_from_hand(amount: int) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var count := mini(maxi(amount, 0), _villain.deck.cards_in_hand())
	if count <= 0:
		return outcome
	var cards: Array[CardData] = await choose_cards_from_hand(count)
	outcome.append(_villain.discard_from_hand(cards))
	_villain_visuals.refresh_stats()
	for card: CardData in cards:
		_villain_visuals.remove_from_hand(card)
	return outcome


# TODO: Keep the adapter's public API limited to VillainPort; move this operation behind the port contract.
func show_hand() -> void:
	await _villain_visuals.add_to_hand(_villain.deck.display_hand())
	_villain_visuals.refresh_stats()


# TODO: Keep the adapter's public API limited to VillainPort; move this operation behind the port contract.
func restore_hand(cards: Array[CardData]) -> void:
	await _villain_visuals.restore_hand(cards)
	_villain_visuals.change_current_symbol(_villain.current_symbol)


func _synchronize_presentation() -> void:
	await _synchronize_hand_and_stats()
	_villain_visuals.change_current_symbol(_villain.current_symbol)


func _synchronize_hand_and_stats() -> void:
	await _villain_visuals.restore_hand(_villain.deck.display_hand())


func _forward_interaction_logged(entry: AuditLogEntry) -> void:
	interaction_logged.emit(entry)


func _on_current_symbol_changed(symbol: Villain.Symbol) -> void:
	_villain_visuals.change_current_symbol(symbol)


func _on_symbol_completed(symbol: Villain.Symbol) -> void:
	_villain_visuals.change_completed_symbol(symbol)
