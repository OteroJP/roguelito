class_name UpkeepLoop extends LoopPhase
	
var _hero
var _villain

func _init(
	villain_character, 
	hero_character
	) -> void:
	_hero = hero_character
	_villain = villain_character

	
func run() -> void:
	await _hero.get_ready() # Hero shows stance
	await _hero.play_card() # Hero shows play intent of its card
	await _villain.draw() # villaino roba 1 carta 
	if _have_loop_ended.call():
		return
	# Si no le quedan cartas, pierde 1 de vida, mezcla su descarte en un nuevo mazo y roba.
	# on_upkeep effects.
	
