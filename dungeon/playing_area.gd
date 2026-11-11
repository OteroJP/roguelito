class_name PlayingArea
extends PanelContainer

@onready var _card_slots: Array[CardSlot] = [
	CardSlot.new(get_node("%CardSlotOne") as PanelContainer),
	CardSlot.new(get_node("%CardSlotTwo") as PanelContainer),
]


func set_card_slots_enabled(enabled_by_slot: Array[bool]) -> void:
	assert(enabled_by_slot.size() == _card_slots.size())
	for index in _card_slots.size():
		_card_slots[index].set_enabled(enabled_by_slot[index])


func add_card(card_data: CardData, face_up: bool = false) -> void:
	for slot in _card_slots:
		if not slot.is_empty():
			continue
		var card := CardViewFactory.create_card_view(card_data)
		await slot.add_card(card, face_up)
		return
	assert(false, "No empty PlayingArea slot remains.")


func reveal_card(card_data: CardData) -> void:
	var slot := _slot_for(card_data)
	if slot != null:
		slot.reveal_card()


func reveal_cards() -> void:
	for slot in _card_slots:
		slot.reveal_card()
		await get_tree().process_frame


func clear() -> void:
	for slot in _card_slots:
		slot.clear()
	await get_tree().create_timer(GameManager.ux_delay).timeout


func discard_card(card_data: CardData) -> void:
	var slot := _slot_for(card_data)
	if slot == null:
		return
	slot.remove_card()


func resolve_card(card_data: CardData) -> void:
	var slot := _slot_for(card_data)
	if slot != null:
		await slot.resolve_card()


func _slot_for(card_data: CardData) -> CardSlot:
	for slot in _card_slots:
		if slot.has_card_data(card_data):
			return slot
	return null


class CardSlot:
	extends RefCounted

	var _panel: PanelContainer
	var _content: MarginContainer
	var _cancelled_overlay: TextureRect
	var _card: Card


	func _init(panel: PanelContainer) -> void:
		_panel = panel
		_content = _panel.get_child(0) as MarginContainer
		_cancelled_overlay = _panel.get_child(1) as TextureRect


	func is_empty() -> bool:
		return _card == null


	func has_card_data(card_data: CardData) -> bool:
		return _card != null and _card.select_card() == card_data


	func set_enabled(enabled: bool) -> void:
		_cancelled_overlay.visible = not enabled


	func add_card(card: Card, face_up: bool) -> void:
		_card = card
		_content.add_child(_card)
		_set_card_visibility(_card, face_up)
		await _flash_stylebox_color(Color.WHITE, Color.WEB_GRAY, 0.5, 1)
		await _panel.get_tree().create_timer(GameManager.ux_delay).timeout


	func reveal_card() -> void:
		if _card != null:
			_set_card_visibility(_card, true)


	func remove_card() -> void:
		if _card == null:
			return
		_content.remove_child(_card)
		_card.queue_free()
		_card = null


	func clear() -> void:
		remove_card()
		_cancelled_overlay.hide()


	func resolve_card() -> void:
		if _card != null:
			await _flash_stylebox_color(Color.GOLD, Color.WEB_GRAY, 0.5, 1)


	func _set_card_visibility(card: Card, enabled: bool) -> void:
		if card.has_method("enable_visibility"):
			card.call("enable_visibility", enabled)


	func _flash_stylebox_color(
		flash_col: Color,
		original_col: Color,
		duration: float = 0.1,
		flashes: int = 3
	) -> void:
		var stylebox := _panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		_panel.add_theme_stylebox_override("panel", stylebox)
		var tween := _panel.create_tween().set_loops(flashes)
		tween.tween_property(stylebox, "bg_color", flash_col, duration / 2.0)
		tween.tween_property(stylebox, "bg_color", original_col, duration / 2.0)
		await tween.finished
		_panel.remove_theme_stylebox_override("panel")
