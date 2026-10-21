@abstract
class_name Card
extends PanelContainer

signal card_clicked(card: CardData)


@abstract
func select_card() -> CardData


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		card_clicked.emit(select_card())
