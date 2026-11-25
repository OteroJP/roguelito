@tool
@abstract class_name CardData
extends Resource

@export var name: String
@export var speed: int
@export var art: Texture2D
@export var bonus_effects: Array[Effect]:
	set(value):
		bonus_effects = _effects_for_card(value)
@export var effects: Array[Effect]:
	set(value):
		effects = _effects_for_card(value)
@export_multiline() var extra_text: String

var _localize_enabled: bool = false


@abstract func bonus_condition_met(character: Character) -> bool


func _init() -> void:
	if Engine.is_editor_hint():
		_enable_effect_localization.call_deferred()


func _enable_effect_localization() -> void:
	_localize_enabled = true


func effect_text() -> String:
	var lines := _effect_lines(effects)
	var tooltip := extra_text.strip_edges()
	if not tooltip.is_empty():
		lines.append(tooltip)
	return "\n".join(lines)


func bonus_effect_text() -> String:
	return "\n".join(_effect_lines(bonus_effects))


func _effects_for_card(list: Array[Effect]) -> Array[Effect]:
	if Engine.is_editor_hint() and _localize_enabled:
		list = _localize_effects(list)
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


func _effect_lines(effect_list: Array[Effect]) -> PackedStringArray:
	var lines := PackedStringArray()
	for effect in effect_list:
		if effect == null:
			continue
		var line := effect.effect_text.strip_edges()
		if not line.is_empty():
			lines.append(line)
	return lines
