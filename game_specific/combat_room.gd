class_name CombatRoom extends Node

@export var villain: Villain 	# Capaz va character aca
@export var hero: Hero 			# Capaz va character aca
@export var ux_delay: float = 0.5

var _combat_loop: CombatLoop
var _logger: GameLogger
var _audit_report: AuditReport = AuditReport.new()

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
	await _combat_loop.run()
	_logger.log("Combat loop ended")
	_end_combat()
	

func _prepare_room() -> void:
	hero.audit_report = _audit_report
	villain.audit_report = _audit_report
	GameManager.prepare(
		playing_area,
		hero,
		villain,
		ux_delay
	)
	playing_area.clear()
	_logger.log("Preparing hero, decks and villain")
	villain_container.add_child(villain.prepare())
	var new_hero: HeroVisuals = hero.prepare()
	dungeon.add_child(new_hero)
	
	_combat_loop = CombatLoop.new(
		_prepare_end_conditions(),
		_prepare_phases(),
		_audit_report,
	)
	_combat_loop.phase_ended.connect(_logger.display_report)


func _end_combat() -> void:
	# TBD
	pass


func _prepare_end_conditions() -> Array[EndCondition]:
	var villain_defeated = CharacterDefeated.new(villain)
	var hero_defeated = CharacterDefeated.new(hero)
	villain_defeated.satisfied.connect(func(_condition: EndCondition) -> void: _audit_report.add("Player lost", AuditLogEntry.Source.GAME))
	hero_defeated.satisfied.connect(func(_condition: EndCondition) -> void: _audit_report.add("Hero defeated!", AuditLogEntry.Source.HERO))
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
