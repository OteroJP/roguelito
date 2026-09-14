class_name Deck
extends Resource

signal deck_shuffle(deck_size: int)
signal cards_moved()


@export var card_set: Dictionary[CardData, int] = {}
@export var side_deck: Dictionary[CardData, int] = {}
@export_range(1,20,1) var max_hand_size: int = 1
@export_range(0,20,1) var initial_hand_size: int = 1

@export_group("Runtime variables")
@export var _deck: Array[CardData] = []
@export var _hand: Array[CardData] = []
@export var _playing_area: Array[CardData] = []
@export var _discard_pile: Array[CardData] = []



func prepare() -> void:		
	_deck.clear()
	_discard_pile.clear()
	_hand.clear()
	for card: CardData in card_set:
		for copy: int in card_set[card]:
			_deck.append(card.duplicate(true))
	_deck.shuffle() #without controled seed
	for ix in initial_hand_size:
		_hand.append(_deck.pop_front())


func reshuffle() -> void:
	add_to_deck(_discard_pile)
	_discard_pile.clear()
	_deck.shuffle()
	cards_moved.emit()


func may_draw(amount: int) -> bool:
	return _deck.size() > amount


func draw() -> CardData:
	assert(_deck.size() > 0, "Draw attempt on empty _deck")
	var card: CardData = _deck.pop_front()
	_hand.append(card)
	cards_moved.emit()
	return card
	

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
		+ _deck.size()  
		)


func cards_in_deck() -> int:
	return _deck.size()


func cards_in_hand() -> int:
	return _hand.size()


func cards_in_discard() -> int:
	return _discard_pile.size()


func display_deck() -> Array[CardData]:
	return _deck.duplicate(false)


func display_hand() -> Array[CardData]:
	return _hand.duplicate(false)


func display_discard_pile() -> Array[CardData]:
	return _hand.duplicate(false)


func put_on_top_deck(extra_cards: Array[CardData]) -> void:
	extra_cards.append_array(_deck)
	_deck = extra_cards
	
	
func put_on_bottom_deck(extra_cards: Array[CardData]) -> void:	
	_deck.append_array(extra_cards)	


func add_to_deck(extra_cards: Array[CardData]) -> void:
	for card: CardData in extra_cards:
		_deck.append(card)
	_deck.shuffle()
	deck_shuffle.emit(_deck.size())
