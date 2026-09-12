class_name Deck
extends Resource


@export var card_set: Array[CardData] = []
@export var side_deck: Array[CardData] = []


var _current_deck: Array[CardData] = []
var _sorted_cars: Array[CardData] = []


func shuffle_deck() -> void:
	if _current_deck.is_empty():
		_current_deck = card_set.duplicate() #shallow copy
	_sorted_cars = _current_deck
	_sorted_cars.shuffle() #without controled seed


func shuffle_in_deck(extra_cards: Array[CardData]) -> void:
	if extra_cards.all(_is_in_deck):
		_sorted_cars.append_array(extra_cards)
		_sorted_cars.shuffle() #without controled seed


func may_draw() -> bool:
	return _sorted_cars.size() > 0


func draw() -> CardData:
	assert(_sorted_cars.size() > 0, "Draw attempt on empty deck")
	return _sorted_cars.pop_front()
	
	
func put_on_top(extra_cards: Array[CardData]) -> void:
	if extra_cards.all(_is_in_deck):
		extra_cards.append_array(_sorted_cars)
		_sorted_cars = extra_cards
	
	
func put_on_bottom(extra_cards: Array[CardData]) -> void:	
	if extra_cards.all(_is_in_deck):
		_sorted_cars.append_array(extra_cards)	
	
	
func display() -> Array[CardData]:
	return _sorted_cars.duplicate()
	

func take_card(card: CardData) -> void:
	return _sorted_cars.erase(card)
	
	
func add_to_deck(extra_cards: Array[CardData]) -> void:
	for card: CardData in extra_cards:
		_current_deck.append(card)
	shuffle_deck()
	
	
func _is_in_deck(card: CardData) -> bool:
	return _current_deck.has(card)
