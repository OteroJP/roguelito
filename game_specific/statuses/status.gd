@tool
class_name Status
extends Resource
## Use a duration of -1 for infinite statuses

signal status_depleted(status: Status)

@export var name: String = "Generic"
@export var duration: int = 1
@export var status_effects: Array[Effect]:
	set(value):
		status_effects = _effects_for_card(value)
@export_multiline() var extra_text: String
@export_multiline() var effect_text: String:
	get:
		if Engine.is_editor_hint():
			_watch_effects()
		return _compose_effect_text()
	set(_value):
		pass

var _refresh_queued: bool = false
var _refreshing: bool = false
var _localize_enabled: bool = false


func on_tick(villain: Villain, hero: Hero) -> void:
	resolve_status_effects(villain, hero)
	if duration != -1:
		duration -= 1
		if duration <= 0:
			status_depleted.emit(self)


func resolve_status_effects(villain: Villain, hero: Hero):
	for effect in status_effects:
		effect.on_clash(villain, hero)


func _init() -> void:
	if Engine.is_editor_hint():
		_enable_effect_localization.call_deferred()


func _enable_effect_localization() -> void:
	_localize_enabled = true


func _effects_for_card(list: Array[Effect]) -> Array[Effect]:
	if Engine.is_editor_hint() and _localize_enabled and not _refreshing:
		list = _localize_effects(list)
	if not _refreshing:
		_queue_refresh()
	return list


func _localize_effects(list: Array[Effect]) -> Array[Effect]:
	var localized: Array[Effect] = []
	var seen: Array[Effect] = []
	for effect in list:
		if effect != null and (effect in seen or not _is_local_effect(effect)):
			effect = effect.duplicate(true) as Effect
		localized.append(effect)
		if effect != null:
			seen.append(effect)
	return localized


func _is_local_effect(effect: Effect) -> bool:
	var path := effect.resource_path
	if path.is_empty():
		return true
	return not resource_path.is_empty() and path.begins_with(resource_path + "::")


func _validate_property(property: Dictionary) -> void:
	if property.name == "card_text":
		property.usage |= PROPERTY_USAGE_READ_ONLY
		property.usage &= ~PROPERTY_USAGE_STORAGE


func _set(property: StringName, value: Variant) -> bool:
	if property == &"card_text":
		return false
	if _refreshing or _ignores_refresh(property):
		return false
	if get(property) != value:
		_queue_refresh()
	return false


func _get(property: StringName) -> Variant:
	if property == &"card_text":
		return _compose_effect_text()
	return null


func _ignores_refresh(property: StringName) -> bool:
	if property == &"script" or property == &"resource_path" or property == &"resource_name" or property == &"resource_local_to_scene":
		return true
	return str(property).begins_with("metadata/")


func _queue_refresh() -> void:
	if not Engine.is_editor_hint() or _refresh_queued:
		return
	_refresh_queued = true
	_refresh_inspector.call_deferred()


func _refresh_inspector() -> void:
	_refresh_queued = false
	_refreshing = true
	notify_property_list_changed()
	emit_changed()
	_refreshing = false


func _watch_effects() -> void:
	for effect in status_effects:
		_watch_effect(effect)


func _watch_effect(effect: Effect) -> void:
	if effect == null:
		return
	if not effect.changed.is_connected(_queue_refresh):
		effect.changed.connect(_queue_refresh)


func _compose_effect_text() -> String:
	var lines := _effect_lines(status_effects)
	var tooltip := extra_text.strip_edges()
	if not tooltip.is_empty():
		lines.append(tooltip)
	return "\n".join(lines)


func _effect_lines(effect_list: Array[Effect]) -> PackedStringArray:
	var lines := PackedStringArray()
	for effect in effect_list:
		if effect == null:
			continue
		var line := effect.effect_text.strip_edges()
		if not line.is_empty():
			lines.append(line)
	return lines
