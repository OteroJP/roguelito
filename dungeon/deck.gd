class_name Deck
extends Resource

signal card_drawn(card: CardData)

@export var card_set: Array[CardData] = []
@export var side_deck: Array[CardData] = []


var _current_deck: Array[CardData] = []
var _sorted_cards: Array[CardData] = []


func shuffle_deck() -> void:
	if _current_deck.is_empty():
		_current_deck = card_set.duplicate() #shallow copy
	_sorted_cards = _current_deck
	_sorted_cards.shuffle() #without controled seed


func shuffle_in_deck(extra_cards: Array[CardData]) -> void:
	if extra_cards.all(_is_in_deck):
		_sorted_cards.append_array(extra_cards)
		_sorted_cards.shuffle() #without controled seed


func may_draw(amount: int) -> bool:
	return _sorted_cards.size() > amount


func get_from_top(amount: int) -> Array[CardData]:
	assert(amount > cards_left(), "Draw attempt of %d cards from deck with %d" % [amount, cards_left()])
	var card: CardData = _sorted_cards.pop_front()
	card_drawn.emit(card)
	return card


func draw() -> CardData:
	assert(_sorted_cards.size() > 0, "Draw attempt on empty deck")
	var card: CardData = _sorted_cards.pop_front()
	card_drawn.emit(card)
	return card
	

func size() -> int:
	return _current_deck.size()


func cards_left() -> int:
	return _sorted_cards.size()


func display() -> Array[CardData]:
	return _sorted_cards.duplicate()


func put_on_top(extra_cards: Array[CardData]) -> void:
	if extra_cards.all(_is_in_deck):
		extra_cards.append_array(_sorted_cards)
		_sorted_cards = extra_cards
	
	
func put_on_bottom(extra_cards: Array[CardData]) -> void:	
	if extra_cards.all(_is_in_deck):
		_sorted_cards.append_array(extra_cards)	


func add_to_deck(extra_cards: Array[CardData]) -> void:
	for card: CardData in extra_cards:
		_current_deck.append(card)
	shuffle_deck()
	

func take_card(card: CardData) -> void:
	return _sorted_cards.erase(card)


func _is_in_deck(card: CardData) -> bool:
	return _current_deck.has(card)
