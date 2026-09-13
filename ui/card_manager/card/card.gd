class_name Card
extends PanelContainer

signal card_clicked(data: CardData)

const CARD_SCENE: PackedScene = preload("uid://0y7udeiiin3i")

var _data: CardData

@onready var art_frame: TextureRect = %Ilustration
@onready var name_tag: Label = %Title
@onready var effect_box: RichTextLabel = %Effect


static func new_card(data: CardData) -> Card:
	var card: Card = CARD_SCENE.instantiate()
	card._setup(data)
	return card
	

func select_card() -> CardData:
	return _data


func _setup(data: CardData) -> void:
	_data = data
	art_frame.texture = data.art
	name_tag.text = data.name
	effect_box.text = data.effects_text()
