class_name DiscardManager extends PanelContainer


var _discard_pile: Array[CardData] = []
var _Counter: SpinBox 


func prepare() -> void:
	_Counter = SpinBox.new()
	_Counter.name = "Counter"
	_Counter.add_theme_font_size_override("DiscardManager", 28)
	add_child(_Counter)
	_discard_pile = []
	# signal connection, when should be added to discard
	_update_counter()


func clear() ->  Array[CardData]:
	var cards_to_be_discarded : Array[CardData] = _discard_pile
	_discard_pile = []
	_update_counter()
	return cards_to_be_discarded
	

func get_from_discard(cards: Array[CardData]) -> Array[CardData]:
	_discard_pile = _discard_pile.filter(cards.has)
	var cards_got: Array[CardData] = _discard_pile.duplicate()
	cards_got.shuffle()
	_update_counter()
	return cards_got


func add_to_discard(cards: Array[CardData]) -> void:
	_discard_pile.append_array(cards)
	_discard_pile.shuffle()
	_update_counter()


func display() -> Array[CardData]:
	return _discard_pile.duplicate()


func _update_counter() -> void:
	_Counter.range.value  = _discard_pile.size()
