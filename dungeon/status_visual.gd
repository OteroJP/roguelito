class_name StatusIcon
extends Control

@onready var icon_rect: TextureRect = %TextureRect
@onready var duration_label: Label = %Duration
@onready var effect_overlay: PanelContainer = %EffectOverlay
@onready var effect_label: Label = %EffectText

var status: Status

static func new_status_icon(_status: Status) -> StatusIcon:
	var status_icon: StatusIcon = UIAssets.STATUS_ICON_SCENE.instantiate() as StatusIcon
	status_icon.status = _status
	return status_icon

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	duration_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if status:
		icon_rect.texture = status.art
		status.status_ticked.connect(update)
		status.status_depleted.connect(queue_free)
		update()


func update() -> void:
	_shake_sprite()
	if status.duration == -1:
		duration_label.text = "∞"
	else:
		duration_label.text = str(status.duration)
	
	
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
	if status == null:
		return
	var text := status.effect_text.strip_edges()
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
