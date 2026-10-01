class_name SymbolCounter
extends PanelContainer

@onready var label: Label = %Count
@onready var symbol_texture: TextureRect = %Symbol
@onready var bonus_texture: TextureRect = %Bonus

var _data: SymbolBonus
var count: int = 0:
	set(_count):
		count = _count
		label.text = str(count)
	
func _ready() -> void:
	symbol_texture.texture = UIAssets.SYMBOL_LIBRARY[_data.symbol]
	bonus_texture.texture = _data.ui_asset
	
func get_symbol() -> Villain.Symbol:
	return _data.symbol
	
static func new_symbol_counter(data: SymbolBonus) -> SymbolCounter:
	var counter: SymbolCounter = UIAssets.SYMBOL_COUNTER_SCENE.instantiate() as SymbolCounter
	counter._data = data
	counter.name = "%s Counter" % str(counter._data.symbol)
	return counter
	
