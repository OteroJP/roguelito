class_name StatIcon
extends Control

@onready var icon_rect: TextureRect = %TextureRect
@onready var value_label: Label = %Value
@onready var effect_overlay: PanelContainer = %EffectOverlay
@onready var effect_label: Label = %EffectText

var character: Character
var _effect_text: String = ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	if character:
		character.modifiers_changed.connect(refresh)
		refresh()


func refresh() -> void:
	pass


func _apply_amount(amount: int, effect_text: String) -> void:
	_set_effect_text(effect_text)
	if amount == 0:
		_hide_icon()
		return
	var next_text := _format_amount(amount)
	var changed := not visible or value_label.text != next_text
	value_label.text = next_text
	visible = true
	if changed:
		_shake_sprite()


func _apply_active(active: bool, effect_text: String) -> void:
	_set_effect_text(effect_text)
	if not active:
		_hide_icon()
		return
	var changed := not visible
	visible = true
	if changed:
		_shake_sprite()


func _set_effect_text(effect_text: String) -> void:
	_effect_text = effect_text
	if effect_overlay.visible:
		effect_label.text = effect_text


func _hide_icon() -> void:
	visible = false
	effect_overlay.visible = false
	z_index = 0


func _format_amount(amount: int) -> String:
	if amount > 0:
		return "+%d" % amount
	return str(amount)


func _shake_sprite() -> void:
	var original_position: Vector2 = icon_rect.position
	var tween: Tween = create_tween().set_parallel(false)
	var step_duration: float = 0.4 / 12
	for i in 10:
		var random_offset: Vector2 = Vector2(
			randf_range(-8.0, 8.0),
			randf_range(-8.0, 8.0)
		)
		tween.tween_property(icon_rect, "position", original_position + random_offset, step_duration)
	tween.tween_property(icon_rect, "position", original_position, step_duration)
	await tween.finished


func _on_mouse_entered() -> void:
	var text := _effect_text.strip_edges()
	if text.is_empty():
		return
	effect_label.text = text
	effect_overlay.top_level = true
	effect_overlay.visible = true
	z_index = 1
	effect_overlay.reset_size()
	var overlay_size := effect_overlay.get_combined_minimum_size()
	var origin := global_position + Vector2((size.x - overlay_size.x) * 0.5, -overlay_size.y - 2.0)
	if origin.y < 0.0:
		origin.y = global_position.y + size.y + 2.0
	effect_overlay.global_position = origin


func _on_mouse_exited() -> void:
	effect_overlay.visible = false
	z_index = 0
