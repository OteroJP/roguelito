class_name PlayingArea
extends PanelContainer

@onready var _card_slot_panels: Array[PanelContainer] = [
	get_node("%CardSlotOne") as PanelContainer,
	get_node("%CardSlotTwo") as PanelContainer,
]
@onready var _card_slot_containers: Array[MarginContainer] = [
	get_node("%CardSlotOneContent") as MarginContainer,
	get_node("%CardSlotTwoContent") as MarginContainer,
]
@onready var _cancellation_overlays: Array[TextureRect] = [
	get_node("%CardSlotOneCancelledOverlay") as TextureRect,
	get_node("%CardSlotTwoCancelledOverlay") as TextureRect,
]

var _slot_by_card_data: Dictionary[CardData, int] = {}


func set_card_slots_enabled(enabled_by_slot: Array[bool]) -> void:
	assert(
		enabled_by_slot.size() == _cancellation_overlays.size(),
		"Card slot state count must match the PlayingArea slot count."
	)
	for slot_index in enabled_by_slot.size():
		_cancellation_overlays[slot_index].visible = not enabled_by_slot[slot_index]


func add_card(card_data: CardData, face_up: bool = false) -> void:
	# Cards take slots in arrival order; clear() starts the order again.
	for slot_index in _card_slot_containers.size():
		var container := _card_slot_containers[slot_index]
		if not container.get_children().is_empty():
			continue
		var card_view := CardViewFactory.create_card_view(card_data)
		if card_view == null:
			return
		_slot_by_card_data[card_data] = slot_index
		_set_card_visibility(card_view, face_up)
		container.add_child(card_view)
		await flash_stylebox_color(
			_card_slot_panels[slot_index],
			Color.WHITE,
			Color.WEB_GRAY,
			0.5,
			1
		)
		await get_tree().create_timer(GameManager.ux_delay).timeout
		return
	assert(false, "No empty PlayingArea slot remains.")


func _set_card_visibility(card_view: PanelContainer, enabled: bool) -> void:
	if card_view != null and card_view.has_method("enable_visibility"):
		card_view.call("enable_visibility", enabled)


func reveal_card(card_data: CardData) -> void:
	var slot_index := _slot_index_for(card_data)
	if slot_index == -1:
		return
	_set_card_visibility(_card_view_in_slot(slot_index), true)


func reveal_cards() -> void:
	for container: MarginContainer in _card_slot_containers:
		for child: Node in container.get_children():
			_set_card_visibility(child as PanelContainer, true)


func clear() -> void:
	for container: MarginContainer in _card_slot_containers:
		for child: Node in container.get_children():
			container.remove_child(child)
			child.queue_free()
	_slot_by_card_data.clear()
	for overlay: TextureRect in _cancellation_overlays:
		overlay.visible = false
	await get_tree().create_timer(GameManager.ux_delay).timeout


func discard_card(card_data: CardData) -> void:
	var slot_index := _slot_index_for(card_data)
	if slot_index == -1:
		return
	var container := _card_slot_containers[slot_index]
	var card_view := _card_view_in_slot(slot_index)
	if card_view == null:
		_slot_by_card_data.erase(card_data)
		return
	container.remove_child(card_view)
	card_view.queue_free()
	_slot_by_card_data.erase(card_data)


func resolve_card(card_data: CardData) -> void:
	var slot_index := _slot_index_for(card_data)
	if slot_index == -1:
		return
	await flash_stylebox_color(
		_card_slot_panels[slot_index],
		Color.GOLD,
		Color.WEB_GRAY,
		0.5,
		1
	)


func _card_view_in_slot(slot_index: int) -> PanelContainer:
	var container := _card_slot_containers[slot_index]
	if container.get_child_count() == 0:
		return null
	return container.get_child(0) as PanelContainer


func _slot_index_for(card_data: CardData) -> int:
	var slot_index: int = _slot_by_card_data.get(card_data, -1)
	return slot_index


func flash_stylebox_color(
	panel: PanelContainer,
	flash_col: Color,
	original_col: Color,
	duration: float = 0.1,
	flashes: int = 3
) -> void:
	var stylebox := panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	panel.add_theme_stylebox_override("panel", stylebox)
	var tween := create_tween().set_loops(flashes)
	tween.tween_property(stylebox, "bg_color", flash_col, duration / 2.0)
	tween.tween_property(stylebox, "bg_color", original_col, duration / 2.0)
	await tween.finished
	panel.remove_theme_stylebox_override("normal")
