class_name Card
extends PanelContainer

signal card_clicked(card: Card)

const CARD_SCENE: PackedScene = preload("uid://0y7udeiiin3i")

var _data: CardData
@onready var _art_frame: TextureRect = %Ilustration
@onready var _name_tag: Label = %Title
@onready var _effect_label: Label = %Effect
var _bonus_effect_label: Label
var _symbol_finish: TextureRect
var _symbol_start: TextureRect


static func new_card(data: CardData) -> Card:
	var card: Card = CARD_SCENE.instantiate()
	card._setup(data)
	return card
	

func select_card() -> CardData:
	return _data


func _gui_input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
	and event.button_index == MOUSE_BUTTON_LEFT
	and event.is_released()
	):
		card_clicked.emit(select_card())
