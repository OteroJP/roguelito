class_name CombatRoom extends Node

@export var villain: Villain 	# Capaz va character aca
@export var hero: Hero 			# Capaz va character aca

var _combat_loop: CombatLoop

@onready var villain_container: MarginContainer = %InteractiveContainer
@onready var dungeon: Node2D = %DungeonRoom

func _ready() -> void:
	_prepare_combat() #await?
	
	#Add villain node
	villain_container.add_child(villain.create_node())
	dungeon.add_child(hero.create_node())
	#TODO Add heor node
	
	await start_combat()
	
	
func start_combat() -> void:
	_combat_loop = CombatLoop.new(
		_prepare_end_conditions(),
		_prepare_phases(),	
	)
	await _combat_loop.run()
	_end_combat()
	

func _prepare_combat() -> void:
	print("Preparing hero, decks and villain")
	# get and store the hero 
	# get and store the villain


func _prepare_end_conditions() -> Array[EndCondition]:
	var villain_defeated = CharacterDefeated.new(villain)
	var hero_defeated = CharacterDefeated.new(hero)
	villain_defeated.satisfied.connect(print.bind("Player lost"))
	villain_defeated.satisfied.connect(print.bind("Hero defeated!"))
	return [
		villain_defeated,
		hero_defeated
	]
	#end_conditions
	
	
func _prepare_phases() -> Array[LoopPhase]:
	return [
		UpkeepLoop.new(hero, villain),
		PlayerTurn.new(villain),
		Resolution.new()
		]


func _end_combat() -> void:
	pass
