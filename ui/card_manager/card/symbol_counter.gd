class_name SymbolCount
extends PanelContainer

@onready var label: Label = %Count
@onready var text_rect: TextureRect = %Symbol

@export var symbol: Villain.Symbol
@export var count: int = 0:
	set(_count):
		count = _count
		label.text = str(count)
	
func _ready() -> void:
	text_rect.texture = UIAssets.SYMBOL_LIBRARY[symbol]
