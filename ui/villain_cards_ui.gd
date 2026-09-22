class_name VillainCardsUI extends HBoxContainer

#signal hand_changed()

var _deck: Deck
var _chosen_card: CardData

@onready var _DeckContainer: MarginContainer = %DeckContainer
@onready var _HandContainer: MarginContainer = %HandContainer
@onready var _DiscardContainer: MarginContainer = %DiscardContainer

@onready var _Deck: Label = %Deck
@onready var _Hand: HBoxContainer = %Hand
@onready var _Discard: SpinBox = %Discard
@onready var _ConfirmButton: Button = %ConfirmButton
@onready var _CancelButton: Button = %CancelButton


func _ready() -> void:
	_CancelButton.pressed.connect(_cancel_selection)


func prepare(new_deck: Deck) -> void:
	_deck = new_deck
	_deck.cards_moved.connect(_update_counters)

#TODO revisar esto
func add_to_hand(cards: Array[CardData]) -> void:
	var card_nodes: Array[Control] = []

	for data: CardData in cards:
		var card: Card = Card.new_card(data)
		if _Hand:
			_Hand.add_child(card)
		card.offset_transform_enabled = true
		card.offset_transform_visual_only = true
		card_nodes.append(card) 	#TODO: think a zero-copy, statically typed solution bypassing current GDScript limitations
	
	await get_tree().process_frame # Wait until the HBoxContainer has arranged its children.
	var animated_translation: Tween = _translation_tween(card_nodes)
	await animated_translation.finished

#
func choose_card() -> CardData:
	print("Choosing card")
	_set_hand_interactable(true)
	await _ConfirmButton.pressed
	var card_selected: CardData = _chosen_card
	_cancel_selection()
	_set_hand_interactable(false)
	return card_selected


#TODO revisar esto
func remove_from_hand(card_data: CardData) -> void:
	#TODO animaciones sonidos y todo eso
	var card_to_remove: Card = _find_card_in_hand(card_data)
	#tween to visually move outside
	_Hand.remove_child(
		card_to_remove
	)
	#if card_to_remove:
		#hand_changed.emit()
	#GameManager.current_villain_card = card_data
	#_deck.play(card_data)


func _update_counters() -> void:
	#TODO animacion de como sube el numero y otras visuales
	_Discard.range.value  = _deck.cards_in_discard()
	_Deck.text = "%d / %d" % [_deck.cards_in_deck(), _deck.size()]
	# update deck label


func _find_card_in_hand(data: CardData) -> Card:
	var card_ix = _Hand.get_children().find_custom(
		func(card_node: Card):
			return card_node.match_data(data)
	)
	return _Hand.get_children().get(card_ix)


func _set_hand_interactable(enabled: bool) -> void:
	for card: Card in _Hand.get_children():
		card.set_process_input(enabled)
		if enabled:
			card.card_clicked.connect(_chose_card)		
		else:
			card.card_clicked.disconnect(_chose_card)		
	

func _chose_card(card: CardData) -> void:
	_chosen_card = card
	_CancelButton.show()
	_ConfirmButton.show()
	_CancelButton.set_process_input(true)
	_ConfirmButton.set_process_input(true)


func _cancel_selection() -> void:
	_chosen_card = null
	_CancelButton.hide()
	_ConfirmButton.hide()
	_CancelButton.set_process_input(false)
	_ConfirmButton.set_process_input(false)
	
	
func _translation_tween(control_nodes: Array[Control]) -> Tween:
	const DELAY_FACTOR: float = 0.08
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	for i: int in control_nodes.size():
		var control: Control = control_nodes[i]
		control.offset_transform_enabled = true
		control.offset_transform_visual_only = true
		translation_tweener(
			tween,
			control,
			i*DELAY_FACTOR
		)
	return tween
	
	
func translation_tweener(
		tween: Tween,
		control: Control,
		delay: float
	) -> void:

	# TODO: make this an export
	const START_DISTANCE := 80.0
	const OVERSHOOT_DISTANCE := 20.0
	const FORWARD_DURATION := 0.25
	const RETURN_DURATION := 0.15

	var start_position: Vector2 = - Vector2(START_DISTANCE, 0.0)
	var overshoot_position: Vector2 = Vector2(OVERSHOOT_DISTANCE, 0.0)

	control.offset_transform_position = start_position
	(tween.tween_property(
			control,
			"offset_transform_position",
			overshoot_position,
			FORWARD_DURATION
		)
		.set_delay(delay)
		.set_trans(Tween.TRANS_QUAD)
		.set_ease(Tween.EASE_OUT)
	)
	(tween.tween_property(
		control,
		"offset_transform_position",
		 Vector2.ZERO,
		RETURN_DURATION
	)
	.set_delay(delay + FORWARD_DURATION)
	.set_trans(Tween.TRANS_BACK)
	.set_ease(Tween.EASE_OUT)
	)
	
