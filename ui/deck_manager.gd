class_name DeckManager extends PanelContainer

var _deck: Deck
var _Display: Label


func prepare(new_deck: Deck) -> void:
	var Display: Label = Label.new()
	Display.name = "Display"
	Display.add_theme_font_size_override("DiscardManager", 28)
	add_child(Display)
	_Display = Display
	_deck = new_deck
	_deck.card_drawn.connect(_update_text)
	_deck.shuffle_deck()
	_update_text()


func shuffle(cards: Array[CardData]) -> void:
	_deck.shuffle_in_deck(cards)
	_update_text()


func _update_text() -> void:
	_Display.text = "%d / %d" % [_deck.cards_left(), _deck.size()]
