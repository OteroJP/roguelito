@tool
@abstract class_name Effect
extends Resource

@export_multiline() var effect_text: String:
	get:
		return _effect_text()
	set(_value):
		pass

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


@abstract func _effect_text() -> String


func on_play(villain: Villain, hero: Hero):
	pass


func on_clash(villain: Villain, hero: Hero):
	pass


func after_clash(villain: Villain, hero: Hero):
	pass


func on_discard(villain: Villain, hero: Hero):
	pass


func text() -> String:
	return effect_text


#DamageEffect
#extends Effect
#var damage: int
#func _on_clash(_target)
	#if  _get_target() and  _get_target().has_metod(“take_damage”):
		#target.take_damage(damage)
