class_name CombatRoom extends Node

var _hero
var _villian
var _combat_loop

func _init(
	villan,
	hero
) -> void:
	_villian = villan
	_hero = hero


func _ready() -> void:
	_prepare_combat()
	_combat_loop = CombatLoop.new(
		_hero,
		_villian,
		_prepare_end_conditions(),
		_prepare_phases(),	
	)
	while _combat_loop.should_continue():
		await _combat_loop.run()
	

func _prepare_combat() -> void:
	print("Preparing hero, decks and villain")


func _prepare_end_conditions() -> Array[EndCondition]:
	return []
	#end_conditions
	
	
func _prepare_phases() -> Array[Loop]:
	return [
		UpkeepLoop.new(_villian, _hero),
		PlayerTurn.new(_villian, _hero),
		CardsResolution.new(_villian, _hero)
		]
