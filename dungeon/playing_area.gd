class_name PlayingArea
extends PanelContainer

@onready var _PlayingColumn: VBoxContainer = %PlayingColumn
@onready var _HeroCardPanel: PanelContainer = %HeroCardPanel
@onready var _VillainCardPanel: PanelContainer = %VillainCardPanel

var _hero_card: HeroCard
var _villain_card: VillainCard

func add_hero_card(card_data: HeroCardData, _visible: bool = false) -> void:
	var hero_card: HeroCard = HeroCard.new_hero_card(GameManager.current_hero_card)
	_hero_card = hero_card
	_HeroCardPanel.get_child(0).add_child(hero_card)
	enable_hero_card_visibility(_visible)
	await flash_stylebox_color(_HeroCardPanel, Color.WHITE, Color.WEB_GRAY, 0.5, 1)
	await get_tree().create_timer(GameManager.ux_delay).timeout


func enable_hero_card_visibility(enabled: bool) -> void:
	_hero_card.enable_visibility(enabled)


func add_villain_card(card_data: VillainCardData, _visible: bool = false) -> void:
	var villain_card: VillainCard = VillainCard.new_villain_card(GameManager.current_villain_card)
	_villain_card = villain_card
	_VillainCardPanel.get_child(0).add_child(villain_card)
	await flash_stylebox_color(_VillainCardPanel, Color.WHITE, Color.WEB_GRAY, 0.5, 1)
	await get_tree().create_timer(GameManager.ux_delay).timeout


func clear() -> void:
	for child: Control in _HeroCardPanel.get_child(0).get_children():
		child.queue_free()
	for child: Control in _VillainCardPanel.get_child(0).get_children():
		child.queue_free()
	_hero_card = null
	_villain_card = null
	await get_tree().create_timer(GameManager.ux_delay).timeout


func resolve_villain_card() -> void:
	await flash_stylebox_color(_VillainCardPanel, Color.GOLD, Color.WEB_GRAY, 0.5, 1)

func resolve_hero_card() -> void:
	await flash_stylebox_color(_HeroCardPanel, Color.GOLD, Color.WEB_GRAY, 0.5, 1)


func flash_stylebox_color(panel: PanelContainer, flash_col: Color, original_col: Color, duration: float = 0.1, flashes: int = 3) -> void:
	var stylebox = panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	panel.add_theme_stylebox_override("panel", stylebox)
	var tween = create_tween().set_loops(flashes)
	tween.tween_property(stylebox, "bg_color", flash_col, duration / 2.0)
	tween.tween_property(stylebox, "bg_color", original_col, duration / 2.0)
	await tween.finished
	panel.remove_theme_stylebox_override("normal")	
