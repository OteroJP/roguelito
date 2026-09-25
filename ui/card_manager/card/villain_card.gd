class_name VillainCard
extends PanelContainer

signal card_clicked(card: VillainCardData)

const CARD_SCENE: PackedScene = preload("uid://ce3fqp227u3vc")
const HOVER_UPWARD_MOVEMENT: float = 20.0 # Pixels to move up

@onready var _art_frame: TextureRect = %Ilustration
@onready var _effect_label: RichTextLabel = %Effect
@onready var _name_tag: Label = %Title
@onready var _back: ColorRect = %CardBack
@onready var _symbol_to_complete: TextureRect = %SymbolToComplete
@onready var _symbol_to_spawn: TextureRect = %SymbolToSpawn

var _data: VillainCardData
var _bonus_effect_label: Label
var _tween: Tween
var _is_hovered: bool = false

func _ready() -> void:
	offset_transform_enabled = true
	offset_transform_visual_only = true
	
# Force the root panel to capture mouse inputs directly
	mouse_filter = Control.MOUSE_FILTER_STOP 
	
	# Set the container holding your UI items to completely ignore mouse events
	# This automatically bypasses all of its internal children!
	$MarginContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if _data:
		_art_frame.texture = _data.art
		_name_tag.text = _data.name
		_effect_label.text = _data.effects_text()
		_symbol_to_complete.texture = UIAssets.SYMBOL_LIBRARY[_data.symbol_to_complete]
		_symbol_to_spawn.texture = UIAssets.SYMBOL_LIBRARY[_data.symbol_to_spawn]


static func new_villain_card(data: VillainCardData) -> VillainCard:
	var card: VillainCard = CARD_SCENE.instantiate() as VillainCard
	card.set_process_input(false)
	card._data = data
	return card
	

func select_card() -> VillainCardData:
	return _data


func match_data(data: VillainCardData) -> bool:
	return _data == data



func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("CARD CLICKED!")
		card_clicked.emit(select_card())



func _on_mouse_entered() -> void:
	if not _is_hovered:
		_is_hovered = true
		_animate_card(Vector2.UP)


func _on_mouse_exited() -> void:
	if _is_hovered:
		_is_hovered = false
		_animate_card(Vector2.ZERO)
	#FIXME it is exiting immediatly
	#await _animate_card(Vector2.ZERO).finished
	#_tween = null



func _animate_card(direction: Vector2) -> Tween:
	if _tween:
		_tween.kill()			
	_tween = create_tween()
	var target_position: Vector2 = HOVER_UPWARD_MOVEMENT*direction
	_tween.tween_property(self, "offset_transform_position", target_position, 0.2)
	_tween.set_trans(Tween.TRANS_QUAD)
	_tween.set_ease(Tween.EASE_OUT)
	return _tween
