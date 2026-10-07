@tool
class_name ResourceIndex
extends Resource

const SNAPSHOTS_ROOT: String = "res://agnostic/content/"
const SLOT_STABLE: String = "stable"
const SLOT_BACKUP: String = "backup"


@export_group("CHARACTERS")
@export var hero: Hero
@export var villain: Villain

@export_group("CARDS")
@export var hero_cards: Array[HeroCardData] = []
@export var villain_cards: Array[VillainCardData] = []

@export_group("CONTENT")
@export var spells: Array[VillainSpell] = []
@export var statuses: Array[Status] = []
@export var symbol_bonuses: Array[SymbolBonus] = []
@export var effects: Array[Effect] = []

@export_category("ACTIONS")
@export_tool_button("Save as Stable (and Stable as Backup)", "Save")
var _btn_save_as_stable: Callable = save_as_stable
@export_tool_button("Reset to Stable", "ReloadSmall")
var _btn_reset_to_stable: Callable = reset_to_stable
@export_tool_button("Reset to Backup", "BackStart")
var _btn_reset_to_backup: Callable = reset_to_backup
#@export_tool_button("Reset to Backup", "BackStart")
#var _btn_line_up: Callable = _force_line_up


func save_as_stable() -> void:
	_for_each_tracked(_promote_one)
	print("ResourceIndex: saved tracked resources as Stable (previous Stable → Backup).")


func reset_to_stable() -> void:
	_for_each_tracked(func(group: String, key: StringName, live: Resource) -> void:
		_reset_one(group, key, live, SLOT_STABLE)
	)
	print("ResourceIndex: reset tracked resources from Stable.")


func reset_to_backup() -> void:
	_for_each_tracked(func(group: String, key: StringName, live: Resource) -> void:
		_reset_one(group, key, live, SLOT_BACKUP)
	)
	print("ResourceIndex: reset tracked resources from Backup.")


func _for_each_tracked(action: Callable) -> void:
	_for_each_single(action, "hero", hero)
	_for_each_single(action, "villain", villain)
	_for_each_group(action, "hero_cards", hero_cards)
	_for_each_group(action, "villain_cards", villain_cards)
	_for_each_group(action, "spells", spells)
	_for_each_group(action, "statuses", statuses)
	_for_each_group(action, "symbol_bonuses", symbol_bonuses)
	_for_each_group(action, "effects", effects)


func _for_each_single(action: Callable, group: String, live: Resource) -> void:
	if live == null:
		push_warning("ResourceIndex: %s is null, skipped." % group)
		return
	action.call(group, _resource_key(live), live)


func _for_each_group(action: Callable, group: String, resources: Array) -> void:
	for live: Resource in resources:
		if live == null:
			push_warning("ResourceIndex: %s contains a null resource, skipped." % group)
			continue
		action.call(group, _resource_key(live), live)


func _resource_key(resource: Resource) -> StringName:
	var resource_path := resource.resource_path
	if resource_path.begins_with("res://resources/"):
		resource_path = resource_path.trim_prefix("res://resources/")
	if resource_path.ends_with(".tres") or resource_path.ends_with(".res"):
		resource_path = resource_path.get_basename()
	if resource_path.is_empty():
		resource_path = resource.resource_name
	return StringName(resource_path)


func _promote_one(group: String, key: StringName, live: Resource) -> void:
	var stable_path := _snapshot_path(SLOT_STABLE, group, key)
	var backup_path := _snapshot_path(SLOT_BACKUP, group, key)
	if ResourceLoader.exists(stable_path):
		_save_snapshot(load(stable_path) as Resource, backup_path)
	_save_snapshot(live, stable_path)


func _reset_one(group: String, key: StringName, live: Resource, slot: String) -> void:
	var path := _snapshot_path(slot, group, key)
	if not ResourceLoader.exists(path):
		push_warning("ResourceIndex: no %s snapshot for %s/%s" % [slot, group, key])
		return
	var snap := load(path) as Resource
	if snap == null:
		push_warning("ResourceIndex: failed to load %s" % path)
		return
	_apply_snapshot(snap, live)


func _snapshot_path(slot: String, group: String, key: StringName) -> String:
	var safe_key := String(key).replace("/", "__").replace("\\", "__").validate_filename()
	if safe_key.is_empty():
		safe_key = String(key).replace("/", "__").replace("\\", "__").replace(":", "_")
	return "%s/%s/%s/%s.tres" % [SNAPSHOTS_ROOT, slot, group, safe_key]


func _save_snapshot(live: Resource, path: String) -> void:
	var abs_dir := ProjectSettings.globalize_path(path.get_base_dir())
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var copy := live.duplicate(true) # REVISAR ESTO PORQUE DSP EN EL PROYECTO USAMOS LOAD
	var err := ResourceSaver.save(copy, path)
	if err != OK:
		push_error("ResourceIndex: failed to save '%s' (error %s)" % [path, err])


func _apply_snapshot(from: Resource, to: Resource) -> void:
	for p in from.get_property_list():
		if (p.usage & PROPERTY_USAGE_STORAGE) == 0:
			continue
		var prop_name: String = p.name
		if prop_name.begins_with("resource_") or prop_name.begins_with("metadata"):
			continue
		var value: Variant = from.get(prop_name)
		if value is Resource:
			var from_res: Resource = value
			if from_res.resource_path.is_empty():
				var existing: Variant = to.get(prop_name)
				if existing is Resource and (existing as Resource).resource_path.is_empty():
					_apply_snapshot(from_res, existing as Resource)
				else:
					to.set(prop_name, from_res.duplicate(true))
			else:
				to.set(prop_name, from_res)
		else:
			to.set(prop_name, value)


func _force_line_up() -> void:
	var active_tree: SceneTree = null
	# 1. Check if we are running in the Editor Viewport or in the Live Game
	if Engine.is_editor_hint():
		# In the Editor, Engine.get_main_loop() returns the main EditorInterface SceneTree
		active_tree = Engine.get_main_loop() as SceneTree
		if active_tree and active_tree.edited_scene_root:
			# Look inside the tab currently open in the editor workspace
			pass
	else:
		# In the running game, Engine.get_main_loop() points to the actual game's SceneTree
		active_tree = Engine.get_main_loop() as SceneTree
		if active_tree and active_tree.root:
			# Look from the running absolute root window down
			active_tree.root.has_node("Track")
			
