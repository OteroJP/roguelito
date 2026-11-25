extends Node

## Owns the state of a run and drives the scene loop:
## main menu -> combat -> rest -> combat -> ... -> main menu when the run ends.
## Lives outside the scenes (autoload) so the run state survives scene changes.
##
## The player controls the villain. Defeating the hero ends the combat and the
## run continues through the rest room; the villain being defeated ends the run.

const COMBAT_SCENE: PackedScene = preload("res://scenes/combat_room.tscn")
const MENU_SCENE: PackedScene = preload("res://scenes/main_menu.tscn")
const REST_SCENE: PackedScene = preload("res://scenes/rest_room.tscn")

const HERO_TEMPLATE: Hero = preload("res://resources/hero.tres")
const VILLAIN_TEMPLATE: Villain = preload("res://resources/villain.tres")

## Options of the active run, or null when no run is active.
var current_options: RunOptions

## Baseline the hero is restored from at the end of a won combat. It starts as
## a copy of the run's hero (template values today) and will also receive the
## hero upgrades, without touching the template resource.
var _hero_reset: Hero


func has_active_run() -> bool:
	return current_options != null


## Starts a fresh run from the base resources and enters the first combat.
func start_run() -> void:
	var hero := HERO_TEMPLATE.duplicate(true) as Hero
	var villain := VILLAIN_TEMPLATE.duplicate(true) as Villain
	var conditions: Array[EndCondition] = [
		CharacterDefeated.new(hero),
		CharacterDefeated.new(villain),
	]
	var options := RunOptions.new()
	options.hero = hero
	options.villain = villain
	options.end_conditions = conditions
	_hero_reset = hero.create_state_copy()
	current_options = options
	_change_scene(COMBAT_SCENE)


## Called by the combat room when the combat loop ends. Reads the end conditions
## to decide what follows: hero defeated continues through rest, villain
## defeated ends the run.
func finish_combat() -> void:
	if not has_active_run():
		return
	if _is_defeated(current_options.hero):
		_rest()
		_change_scene(REST_SCENE)
		return
	if _is_defeated(current_options.villain):
		end_run()


## Leaves the rest room and starts the next combat of the run.
func start_next_combat() -> void:
	if not has_active_run():
		return
	_change_scene(COMBAT_SCENE)


## Ends the run and returns to the main menu.
func end_run() -> void:
	current_options = null
	_hero_reset = null
	_change_scene(MENU_SCENE)


## Rest: the hero is restored to the run baseline, then fully healed (health and
## armor). Upgrades are not implemented yet; they will be applied to the hero and
## to [_hero_reset].
func _rest() -> void:
	var hero := current_options.hero
	hero.restore_hero_state_from(_hero_reset)
	hero.health = hero.max_health
	hero.armor = hero.max_armor
	# TODO: hero upgrade step.


func _is_defeated(character: Character) -> bool:
	for condition in current_options.end_conditions:
		if condition is CharacterDefeated and condition.character == character:
			return condition.was_satisfied()
	return false


func _change_scene(scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(scene)
