class_name HandManager extends HBoxContainer


var _hand: Array[CardData] = []


func prrepare(deck: Deck, initial_hand_size: int) -> void:
	deck.card_drawn.connect(_add_card)
	var initial_hand: Array[CardData] = deck.get_hand(initial_hand_size)
	for card: CardData in initial_hand:
		_add_card(card)


func _add_card(card: CardData) -> void:
	#TODO animaciones sonidos y todo eso
	_hand.append(card)
	add_child(Card.new_card(card))
