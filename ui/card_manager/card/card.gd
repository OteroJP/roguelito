extends PanelContainer
class_name Card

signal card_clicked(data: CardData)

var _data: CardData
var _texture_rect: TextureRect
var _name_label: Label
var _effect_label: Label
var _bonus_effect_label: Label
var _symbol_finish: TextureRect
var _symbol_start: TextureRect

func setup(data: CardData) -> void:
	_data = data
