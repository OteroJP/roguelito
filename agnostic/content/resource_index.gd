@tool
class_name ResourceIndex
extends Resource

const SNAPSHOTS_ROOT: String = "res://agnostic/content/"
const SLOT_STABLE: String = "stable"
const SLOT_BACKUP: String = "backup"


@export_group("MISCLEANEO")
@export var fix_borders: bool
#@export var camera: CameraSettings
#@export var player_state: PlayerState
#@export var store_settings: StoreSettings
#@export var race_settings: RaceSettings

#@export_group("CANICAS")
#@export var marbles: Dictionary[StringName, MarbleStats] = {}

#@export_group("ÍTEMS")
#@export var ítems: Dictionary[StringName, ItemResource] = {}

#@export_group("OBSTÁCULOS")
#@export var obstacles: Dictionary[StringName, ObstacleData] = {}

#@export_group("ZONE BEHAVIORS")
#@export var zone_behaviors: Dictionary[StringName, ZoneBehavior] = {}

#@export_group("MARBLE MODIFIERS")
#@export var marble_modifiers: Dictionary[StringName, MarbleModifier] = {}

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
	print("ResourceIndex: saved Test as Stable (previous Stable → Backup).")


func reset_to_stable() -> void:
	_for_each_tracked(func(group: String, key: StringName, live: Resource) -> void:
		_reset_one(group, key, live, SLOT_STABLE)
	)
	print("ResourceIndex: reset Test from Stable.")


func reset_to_backup() -> void:
	_for_each_tracked(func(group: String, key: StringName, live: Resource) -> void:
		_reset_one(group, key, live, SLOT_BACKUP)
	)
	print("ResourceIndex: reset Test from Backup.")


func _for_each_tracked(action: Callable) -> void:
	_for_each_single(action, "misc", &"camera", player_state)
	_for_each_single(action, "misc", &"player_state", player_state)
	_for_each_single(action, "misc", &"store_settings", store_settings)
	_for_each_single(action, "misc", &"race_settings", race_settings)
	_for_each_group(action, "marbles", marbles)
	_for_each_group(action, "items", ítems)
	_for_each_group(action, "obstacles", obstacles)
	_for_each_group(action, "zone_behaviors", zone_behaviors)
	_for_each_group(action, "marble_modifiers", marble_modifiers)

func _for_each_single(action: Callable, group: String, key: StringName, live: Resource) -> void:
	if live == null:
		push_warning("ResourceIndex: %s '%s' is null, skipped." % [group, key])
		return
	action.call(group, key, live)


func _for_each_group(action: Callable, group: String, dict: Dictionary) -> void:
	for key in dict:
		var live: Resource = dict[key]
		if live == null:
			push_warning("ResourceIndex: %s '%s' is null, skipped." % [group, key])
			continue
		action.call(group, key, live)


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
	var safe_key := String(key).validate_filename()
	if safe_key.is_empty():
		safe_key = String(key).replace("/", "_").replace("\\", "_").replace(":", "_")
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
			
