class_name CombatRoom extends Node

@export var villain: Villain 	# Capaz va character aca
@export var hero: Hero 			# Capaz va character aca
@export var ux_delay: float = 0.5

var _combat_loop: CombatLoop

@onready var villain_container: MarginContainer = %InteractiveContainer
@onready var dungeon: Node2D = %DungeonRoom
@onready var playing_area: VBoxContainer = %PlayingArea

func _ready() -> void:
	_prepare_room()
	await start_combat()
	
	
func start_combat() -> void:
	#TBD initial combat animations
	await villain.show_hand()
	await _combat_loop.run()
	_end_combat()
	

func _prepare_room() -> void:
	print("Preparing hero, decks and villain")
	villain_container.add_child(villain.prepare())
	dungeon.add_child(hero.prepare())
	_combat_loop = CombatLoop.new(
		_prepare_end_conditions(),
		_prepare_phases(),	
	)
	GameManager.hero = hero
	GameManager.villain = villain
	GameManager.ux_delay = ux_delay


func _end_combat() -> void:
	# TBD
	pass


func _prepare_end_conditions() -> Array[EndCondition]:
	var villain_defeated = CharacterDefeated.new(villain)
	var hero_defeated = CharacterDefeated.new(hero)
	villain_defeated.satisfied.connect(print.bind("Player lost"))
	villain_defeated.satisfied.connect(print.bind("Hero defeated!"))
	return [
		villain_defeated,
		hero_defeated
	]
	
	
func _prepare_phases() -> Array[LoopPhase]:
	var phases: Array[LoopPhase] = [
		UpkeepLoop.new(hero, villain),
		PlayerTurn.new(villain),
		Resolution.new(playing_area)
		]
	return phases
