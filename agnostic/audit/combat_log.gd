class_name CombatLog
extends CanvasLayer

const _TOGGLE_ACTION := "toggle_combat_log"

var _legend: RichTextLabel
var _body: RichTextLabel
var _entries: Array[String] = []
var _last_turn_entry: int = 0


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_toggle_action()
	_build_panel()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(_TOGGLE_ACTION):
		visible = not visible
		get_viewport().set_input_as_handled()


func set_legend(bbcode: String) -> void:
	_legend.text = bbcode


func append(line: String, color: String, tag: String) -> void:
	var safe_line := line.replace("[", "[lb]")
	_append_entry("[color=%s][lb]%s[rb] %s[/color]\n" % [color, tag, safe_line])


func append_report(report: String) -> void:
	_append_entry(report)


func make_last_turn() -> void:
	_last_turn_entry = _entries.size()


func erase_last_turn() -> void:
	_entries.resize(_last_turn_entry)
	_body.clear()
	for entry: String in _entries:
		_body.append_text(entry)


func clear() -> void:
	_entries.clear()
	_last_turn_entry = 0
	_body.clear()


func _append_entry(entry: String) -> void:
	_entries.append(entry)
	_body.append_text(entry)


func _ensure_toggle_action() -> void:
	if InputMap.has_action(_TOGGLE_ACTION):
		return
	InputMap.add_action(_TOGGLE_ACTION)
	var key := InputEventKey.new()
	key.keycode = KEY_F1
	InputMap.action_add_event(_TOGGLE_ACTION, key)


func _build_panel() -> void:
	var panel := PanelContainer.new()
	panel.anchor_left = 1.0
	panel.anchor_top = 0.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 0.0
	panel.offset_left = -428.0
	panel.offset_top = 8.0
	panel.offset_right = -8.0
	panel.offset_bottom = 368.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.grow_vertical = Control.GROW_DIRECTION_END
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.06, 0.08, 0.88)
	style.set_content_margin_all(10)
	style.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)

	_legend = RichTextLabel.new()
	_legend.bbcode_enabled = true
	_legend.fit_content = true
	_legend.scroll_active = false
	_legend.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_legend.autowrap_mode = TextServer.AUTOWRAP_OFF
	box.add_child(_legend)

	_body = RichTextLabel.new()
	_body.bbcode_enabled = true
	_body.scroll_active = true
	_body.scroll_following = true
	_body.selection_enabled = true
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD
	_body.custom_minimum_size = Vector2(400, 300)
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_theme_font_size_override("normal_font_size", 15)
	box.add_child(_body)
