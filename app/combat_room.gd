class_name CombatRoom extends Node

@export var villain: Villain 	# Capaz va character aca
@export var hero: Hero 			# Capaz va character aca
@export var ux_delay: float = 0.5

var _combat_loop: CombatLoop

@onready var villain_container: MarginContainer = %InteractiveContainer
@onready var dungeon: Node2D = %DungeonRoom
@onready var playing_area: PlayingArea = %PlayingArea

func _ready() -> void:
	_prepare_room()
	await start_combat()
	
	
func start_combat() -> void:
	#TBD initial combat animations
	await villain.show_hand()
	await _combat_loop.run()
	_end_combat()
	

func _prepare_room() -> void:
	GameManager.prepare(
		playing_area,
		hero,
		villain,
		ux_delay
	)
	playing_area.clear()
	GameManager.add_log("Preparing hero, decks and villain", GameManager.LogSource.GAME)
	villain_container.add_child(villain.prepare())
	var new_hero: HeroVisuals = hero.prepare()
	dungeon.add_child(new_hero)
	
	_combat_loop = CombatLoop.new(
		_prepare_end_conditions(),
		_prepare_phases(),	
	)

func _end_combat() -> void:
	# TBD
	pass


func _prepare_end_conditions() -> Array[EndCondition]:
	var villain_defeated = CharacterDefeated.new(villain)
	var hero_defeated = CharacterDefeated.new(hero)
	villain_defeated.satisfied.connect(func(_condition: EndCondition) -> void: GameManager.add_log("Player lost", GameManager.LogSource.GAME))
	hero_defeated.satisfied.connect(func(_condition: EndCondition) -> void: GameManager.add_log("Hero defeated!", GameManager.LogSource.HERO))
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
