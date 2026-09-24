class_name SymbolCount
extends PanelContainer

@onready var label: Label = %Count
@onready var text_rect: TextureRect = %Symbol

@export var symbol: Villain.Symbol
@export var count: int = 0:
	set(_count):
		count = _count
		label.text = str(count)

var _symbol_library: Dictionary[Villain.Symbol, Texture2D] = {
	Villain.Symbol.NONE: null,
	Villain.Symbol.SKULL: preload("uid://cehsg6vccc7gd"),
	Villain.Symbol.OMEGA: preload("uid://b31undwpa6kjr"),
	Villain.Symbol.HEART: preload("uid://c1teqyuhv6yl8")
	}
	
func _ready() -> void:
	text_rect.texture = _symbol_library[symbol]
