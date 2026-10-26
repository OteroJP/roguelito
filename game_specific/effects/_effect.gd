@tool
@abstract class_name Effect
extends Resource

enum TargetSide { OWNER, OPPONENT }
enum Capability {
	CHARACTER_DATA = 1,
	COMBAT_STATE = 2,
	ATTACK_GENERATOR = 4,
}

@export_flags("Character data", "Combat state", "Attack generator")
var capabilities: int = 0

@export_multiline() var effect_text: String:
	get:
		return _effect_text()
	set(_value):
		pass

@export var target_side: TargetSide = TargetSide.OPPONENT

var _refresh_queued: bool = false
var _refreshing: bool = false


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


func create_execution_copy() -> Effect:
	var execution_copy := get_script().new() as Effect
	for property: Dictionary in get_property_list():
		var usage: int = property.usage
		if (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0:
			continue
		if (usage & PROPERTY_USAGE_STORAGE) == 0:
			continue

		var property_name: StringName = property.name
		var configured_value: Variant = get(property_name)
		if configured_value is Array or configured_value is Dictionary:
			configured_value = configured_value.duplicate(true)
		execution_copy.set(property_name, configured_value)
	return execution_copy


@abstract func _effect_text() -> String


## Runs against the character that owns this effect's source.
## Subclasses may await player input before returning.
func preparation(_effect_owner: Character) -> void:
	pass


func has_capability(capability: int) -> bool:
	return (capabilities & capability) != 0


## Applies this effect to the character selected by target_side.
func apply(_target: Character) -> void:
	assert(
		not has_capability(Capability.CHARACTER_DATA),
		"An effect with the CHARACTER_DATA capability must override apply()."
	)


## Returns typed requests for changes to combat-owned state.
func combat_state_changes() -> Array[CombatStateChange]:
	assert(
		not has_capability(Capability.COMBAT_STATE),
		"An effect with the COMBAT_STATE capability must override combat_state_changes()."
	)
	return []


## Builds an attack using the prepared owner and the chosen target.
func build_attack(_owner: Character, _target: Character) -> Attack:
	assert(
		not has_capability(Capability.ATTACK_GENERATOR),
		"An effect with the ATTACK_GENERATOR capability must override build_attack()."
	)
	return null


func text() -> String:
	return effect_text
