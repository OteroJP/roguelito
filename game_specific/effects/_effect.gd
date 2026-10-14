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


func on_play(villain: Villain, hero: Hero) -> AuditOutcome:
	return AuditOutcome.new()


func on_clash(
	villain_port: VillainPort,
	hero_port: HeroPort,
	combat_manager: CombatManager
) -> AuditOutcome:
	var outcome: AuditOutcome = await _ask_for_interaction(
		villain_port,
		hero_port,
		combat_manager
	)
	var villain := villain_port.get_character()
	var hero := hero_port.get_character()
	outcome.append(
		await _on_clash(villain, hero, villain_port, hero_port, combat_manager)
	)
	await villain_port.update_character(villain)
	await hero_port.update_character(hero)
	villain_port.sync_combat_indicators(
		combat_manager.statuses_for(villain_port),
		combat_manager.attack_modifiers_for(villain_port),
		combat_manager.speed_bonus_for(villain_port)
	)
	hero_port.sync_combat_indicators(
		combat_manager.statuses_for(hero_port),
		combat_manager.attack_modifiers_for(hero_port),
		combat_manager.speed_bonus_for(hero_port)
	)
	_clear_effect_data()
	return outcome


func _ask_for_interaction(
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> AuditOutcome:
	return AuditOutcome.new()


func after_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	return AuditOutcome.new()


func on_discard(villain: Villain, hero: Hero) -> AuditOutcome:
	return AuditOutcome.new()


@abstract func _on_clash(
	villain: Villain,
	hero: Hero,
	villain_port: VillainPort,
	hero_port: HeroPort,
	combat_manager: CombatManager
) -> AuditOutcome


@abstract func _clear_effect_data() -> void


func text() -> String:
	return effect_text


#DamageEffect
#extends Effect
#var damage: int
#func _on_clash(_target)
	#if  _get_target() and  _get_target().has_metod(“take_damage”):
		#target.take_damage(damage)
