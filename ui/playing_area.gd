class_name PlayingArea
extends PanelContainer

@onready var _PlayingColumn: VBoxContainer = %PlayingColumn

var _hero_card: HeroCard
var _villain_card: VillainCard

func add_hero_card(card_data: HeroCardData, _visible: bool = false) -> void:
	var hero_card: HeroCard = HeroCard.new_hero_card(GameManager.current_hero_card)
	_hero_card = hero_card
	_PlayingColumn.add_child(hero_card)
	enable_hero_card_visibility(_visible)
	await get_tree().create_timer(GameManager.ux_delay).timeout


func enable_hero_card_visibility(enabled: bool) -> void:
	_hero_card.enable_visibility(enabled)


func add_villain_card(card_data: VillainCardData, _visible: bool = false) -> void:
	var villain_card: VillainCard = VillainCard.new_villain_card(GameManager.current_villain_card)
	_villain_card = villain_card
	_PlayingColumn.add_child(villain_card)
	await get_tree().create_timer(GameManager.ux_delay).timeout


func clear() -> void:
	for child: Control in _PlayingColumn.get_children():
		child.queue_free()
	_hero_card = null
	_villain_card = null
	await get_tree().create_timer(GameManager.ux_delay).timeout
