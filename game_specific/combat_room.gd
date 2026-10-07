class_name CombatRoom extends Node

@export var villain: Villain 	# Capaz va character aca
@export var hero: Hero 			# Capaz va character aca
@export var ux_delay: float = 0.5

var _combat_loop: CombatLoop
var _combat_input: CombatInput
var _logger: GameLogger
var _villain_visuals: VillainVisuals
var _turn_state: Dictionary = {}

@onready var villain_container: MarginContainer = %InteractiveContainer
@onready var dungeon: Node2D = %DungeonRoom
@onready var playing_area: PlayingArea = %PlayingArea


func _ready() -> void:
	_logger = GameLogger.new()
	add_child(_logger)
	_combat_input = CombatInput.new()
	_prepare_room()
	await start_combat()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if key_event.pressed and not key_event.echo and key_event.ctrl_pressed and key_event.keycode == KEY_R:
		if _combat_loop.request_reset():
			_logger.log("RESET REQUESTED")
			_combat_input.request_reset()
			get_viewport().set_input_as_handled()


func start_combat() -> void:
	#TBD initial combat animations
	await villain.show_hand() #TODO modify this
	_logger.display_cycle_header(_combat_loop.round_number)
	await _combat_loop.run()
	_logger.log("Combat loop ended")
	_end_combat()


func _prepare_room() -> void:
	GameManager.prepare(
		playing_area,
		hero,
		villain,
		ux_delay
	)
	playing_area.clear()
	_logger.log("Preparing hero, decks and villain")
	_villain_visuals = villain.prepare()
	_villain_visuals.set_combat_input(_combat_input)
	_villain_visuals.interaction_logged.connect(_logger.display_entry)
	villain_container.add_child(_villain_visuals)
	var new_hero: HeroVisuals = hero.prepare()
	dungeon.add_child(new_hero)

	_combat_loop = CombatLoop.new(
		_prepare_end_conditions(),
		_prepare_phases(),
		_save_turn_state,
		_restore_turn_state
	)
	_combat_loop.phase_ended.connect(_logger.display_report)
	_combat_loop.phase_started.connect(_logger.display_phase_header)
	_combat_loop.end_cycle.connect(_logger.display_cycle_header)


func _save_turn_state() -> void:
	_turn_state = {
		"hero": hero.save_turn_state(),
		"villain": villain.save_turn_state(),
		"game_manager": GameManager.save_turn_state(),
	}


func _restore_turn_state() -> void:
	if _turn_state.is_empty():
		push_warning("CombatRoom: no saved turn state to restore.")
		return
	_combat_input.clear()
	hero.restore_turn_state(_turn_state["hero"])
	villain.restore_turn_state(_turn_state["villain"])
	GameManager.restore_turn_state(_turn_state["game_manager"])
	await _villain_visuals.restore_hand(villain.deck.display_hand())
	await playing_area.clear()
	await playing_area.update()
	_logger.erase_last_turn()


func _end_combat() -> void:
	# TBD
	pass


func _prepare_end_conditions() -> Array[EndCondition]:
	var villain_defeated = CharacterDefeated.new(villain)
	var hero_defeated = CharacterDefeated.new(hero)
	return [
		villain_defeated,
		hero_defeated
	]


func _prepare_phases() -> Array[LoopPhase]:
	var phases: Array[LoopPhase] = [
		UpkeepLoop.new(hero, villain, playing_area),
		PlayerTurn.new(villain, playing_area, _combat_input),
		Resolution.new(playing_area)
		]
	return phases
