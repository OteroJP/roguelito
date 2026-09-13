class_name CombatRoom extends Node

@export var hero: Resource #: HeroCharacter
@export var villain: Resource #: VillainCharacter

var _combat_loop: CombatLoop

@onready var _card_manager: CardManager = %CardManager


func _ready() -> void:
	_prepare_combat() #await?
	await start_combat()
	
	
	
func start_combat() -> void:
	_combat_loop = CombatLoop.new(
		_prepare_end_conditions(),
		_prepare_phases(),	
	)
	while _combat_loop.should_continue():
		await _combat_loop.run()
	

func _prepare_combat() -> void:
	print("Preparing hero, decks and villain")
	# get and store the hero 
	# get and store the villain


func _prepare_end_conditions() -> Array[EndCondition]:
	return [
		VillainDefeated.new(villain),
		HeroeDefeated.new(hero)
	]
	#end_conditions
	
	
func _prepare_phases() -> Array[LoopPhase]:
	return [
		UpkeepLoop.new(villain, hero),
		PlayerTurn.new(villain, hero),
		#Resolution.new()
		]
