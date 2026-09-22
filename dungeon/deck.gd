class_name Deck
extends Resource

signal deck_shuffle(deck_size: int)
signal cards_moved()


@export var card_set: Dictionary[CardData, int] = {}
@export var side_card_pile: Dictionary[CardData, int] = {}
@export_range(0,20,1) var initial_hand_size: int = 0
@export_range(1,20,1) var max_hand_size: int = 1

@export_group("Runtime variables")
@export var _card_pile: Array[CardData] = []
@export var _hand: Array[CardData] = []
@export var _playing_area: Array[CardData] = []
@export var _discard_pile: Array[CardData] = []



func prepare() -> void:		
	_card_pile.clear()
	_discard_pile.clear()
	_hand.clear()
	for card: CardData in card_set:
		print("card: ", card)
		for copy: int in card_set[card]:
			_card_pile.append(card.duplicate(true))
	_card_pile.shuffle() #without controled seed
	for ix in initial_hand_size:
		_hand.append(_card_pile.pop_front())


func reshuffle() -> void:
	add_to_card_pile(_discard_pile)
	_discard_pile.clear()
	_card_pile.shuffle()
	cards_moved.emit()


func may_draw(amount: int) -> bool:
	return _card_pile.size() > amount


func draw() -> CardData:
	assert(_card_pile.size() > 0, "Draw attempt on empty _card_pile")
	var card: CardData = _card_pile.pop_front()
	_hand.append(card)
	cards_moved.emit()
	return card


func pick_random_card() -> CardData:
	assert(_hand.size() > 0, "Draw attempt on empty _card_pile")
	return _hand.pick_random()


func play(card: CardData) -> void:
	if card in _hand:
		_hand.erase(card)
		_playing_area.append(card)
		card.resolved.connect(resolve)
		cards_moved.emit()
	

func resolve(card: CardData) -> void:
	if card in _playing_area:
		card.resolved.disconnect(resolve)
		_playing_area.erase(card)
		_discard_pile.append(card)
		cards_moved.emit()


func discard(card: CardData) -> void:
	if card in _hand:
		_hand.erase(card)
		_discard_pile.append(card)
		cards_moved.emit()


func size() -> int:
	return (
		_discard_pile.size()
		+ _hand.size() 
		+ _card_pile.size()  
		)


func cards_in_card_pile() -> int:
	return _card_pile.size()


func cards_in_hand() -> int:
	return _hand.size()


func cards_in_discard() -> int:
	return _discard_pile.size()


func display_card_pile() -> Array[CardData]:
	return _card_pile.duplicate(false)


func display_hand() -> Array[CardData]:
	return _hand.duplicate(false)


func display_discard_pile() -> Array[CardData]:
	return _hand.duplicate(false)


func put_on_top_card_pile(extra_cards: Array[CardData]) -> void:
	extra_cards.append_array(_card_pile)
	_card_pile = extra_cards
	
	
func put_on_bottom_card_pile(extra_cards: Array[CardData]) -> void:	
	_card_pile.append_array(extra_cards)	


func add_to_card_pile(extra_cards: Array[CardData]) -> void:
	for card: CardData in extra_cards:
		_card_pile.append(card)
	_card_pile.shuffle()
	deck_shuffle.emit(_card_pile.size())
