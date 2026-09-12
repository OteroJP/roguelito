class_name UpkeepLoop extends Loop
	
var _hero
var _villian

func _init(
	villian_character, 
	hero_character
	) -> void:
	_hero = hero_character
	_villian = villian_character
	
	
func run() -> void:
	await _hero.get_ready() # Hero shows stance
	await _hero.play_card() # Hero shows play intent of its card
	await _villian.draw() # Villano roba 1 carta
	# Si no le quedan cartas, pierde 1 de vida, mezcla su descarte en un nuevo mazo y roba.
	# on_upkeep effects.
	# WIN-LOSS CHECK
