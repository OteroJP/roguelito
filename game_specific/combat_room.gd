class_name CombatRoom extends Node

@export var villain: Villain 	# Capaz va character aca
@export var hero: Hero 			# Capaz va character aca
@export var ux_delay: float = 0.5

var _combat_loop: CombatLoop
# var _combat_input: CombatInput
var _combat_port: CombatPort
var _logger: GameLogger
var _hero_adapter: HeroVisualAdapter
var _villain_adapter: VillainVisualAdapter
var _hero_state: Hero
var _villain_state: Villain
var _combat_manager_state: CombatManager

@onready var villain_container: MarginContainer = %InteractiveContainer
@onready var dungeon: Node2D = %DungeonRoom
@onready var playing_area: PlayingArea = %PlayingArea


func _ready() -> void:
	_logger = GameLogger.new()
	add_child(_logger)
	# _combat_input = CombatInput.new()
	await _prepare_room()
	await start_combat()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if key_event.pressed and not key_event.echo and key_event.ctrl_pressed and key_event.keycode == KEY_R:
		if _combat_loop.request_reset():
			_logger.log("RESET REQUESTED")
			# _combat_input.request_reset()
			get_viewport().set_input_as_handled()


func start_combat() -> void:
	#TBD initial combat animations
	_hero_adapter.prepare_for_combat()
	await _villain_adapter.prepare_for_combat()
	_logger.display_cycle_header(_combat_loop.round_number)
	await _combat_loop.run()
	_logger.log("Combat loop ended")
	_end_combat()


func _prepare_room() -> void:
	_logger.log("Preparing hero, decks and villain")
	_hero_adapter = HeroVisualAdapter.new(hero, dungeon)
	_villain_adapter = VillainVisualAdapter.new(villain, villain_container)
	# here we should expand the report
	var combat_manager := CombatManager.new(
		_hero_adapter,
		_villain_adapter
	)
	_combat_port = VisualCombatAdapter.new(combat_manager, playing_area)
	GameManager.prepare(ux_delay)
	await _combat_port.clear_resolution_display()
	# here we should expand the report

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
	_hero_state = hero.create_state_copy()
	_villain_state = villain.create_state_copy()
	_combat_manager_state = _combat_port.create_state_copy()


func _restore_turn_state() -> void:
	if (
		_hero_state == null
		or _villain_state == null
		or _combat_manager_state == null
	):
		push_warning("CombatRoom: no saved turn state to restore.")
		return
	# _combat_input.clear()
	await _hero_adapter.update_character(_hero_state)
	await _villain_adapter.update_character(_villain_state)
	_combat_port.restore_state_from(_combat_manager_state)
	await _combat_port.clear_resolution_display()
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
		UpkeepLoop.new(_villain_adapter, _hero_adapter, _combat_port),
		PlayerTurn.new(_villain_adapter, _hero_adapter, _combat_port),
		Resolution.new(_villain_adapter, _hero_adapter, _combat_port)
		]
	return phases
