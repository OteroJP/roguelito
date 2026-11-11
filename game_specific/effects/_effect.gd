@tool
@abstract class_name Effect
extends Resource

enum TargetSide { OWNER, OPPONENT }

@export_multiline() var effect_text: String:
	get:
		return _effect_text()
	set(_value):
		pass

@export var target_side: TargetSide = TargetSide.OPPONENT

var _refresh_queued: bool = false
var _refreshing: bool = false


@abstract func _effect_text() -> String


## Prepares an effect using its owner's port.
## Read-only: must not mutate character state. Interaction requests and character
## access go through the port (use port.get_character() for a working copy).
func prepare(_effect_owner_port: CharacterPort) -> void:
	pass


## Requests that the selected Hero card be revealed through the combat presentation.
func requests_hero_card_reveal() -> bool:
	return false


func target_label() -> String:
	return "owner" if target_side == TargetSide.OWNER else "opponent"


## Applies this effect to the selected character. Return true when its data changed.
func apply(_target: Character) -> bool:
	return false


## Returns typed requests for changes to combat-owned state.
func combat_state_changes(_effect_owner: Character) -> Array[CombatStateChange]:
	return []


## Builds an attack using the prepared owner and the chosen target.
func build_attack(_owner: Character, _target: Character) -> Attack:
	return null


func text() -> String:
	return effect_text


func _validate_property(property: Dictionary) -> void:
	if property.name == "effect_text":
		property.usage |= PROPERTY_USAGE_READ_ONLY
		property.usage &= ~PROPERTY_USAGE_STORAGE


func _set(property: StringName, value: Variant) -> bool:
	if property == &"effect_text":
		return false
	if _refreshing or _ignores_refresh(property):
		return false
	if get(property) != value:
		_queue_refresh()
	return false


func _get(property: StringName) -> Variant:
	if property == &"effect_text":
		return _effect_text()
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
