class_name CombatRoom extends Node

@export var villain: Villain 	# Capaz va character aca
@export var hero: Hero 			# Capaz va character aca
@export var ux_delay: float = 0.5

var _combat_loop: CombatLoop
var _logger: GameLogger

@onready var villain_container: MarginContainer = %InteractiveContainer
@onready var dungeon: Node2D = %DungeonRoom
@onready var playing_area: PlayingArea = %PlayingArea


func _ready() -> void:
	_logger = GameLogger.new()
	add_child(_logger)
	_prepare_room()
	await start_combat()


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
	var villain_visuals: VillainVisuals = villain.prepare()
	villain_visuals.interaction_logged.connect(_logger.display_entry)
	villain_container.add_child(villain_visuals)
	var new_hero: HeroVisuals = hero.prepare()
	dungeon.add_child(new_hero)

	_combat_loop = CombatLoop.new(
		_prepare_end_conditions(),
		_prepare_phases()
	)
	_combat_loop.phase_ended.connect(_logger.display_report)
	_combat_loop.phase_started.connect(_logger.display_phase_header)
	_combat_loop.end_cycle.connect(_logger.display_cycle_header)


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
		PlayerTurn.new(villain, playing_area),
		Resolution.new(playing_area)
		]
	return phases
