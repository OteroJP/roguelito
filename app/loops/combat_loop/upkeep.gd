class_name UpkeepLoop extends LoopPhase
	
var _hero: Hero
var _villain: Villain

func _init(
	hero_character: Hero,
	villain_character: Villain
	) -> void:
	_hero = hero_character
	_villain = villain_character

	
func run() -> void:
	print("upkeep started")
	await _hero.draw() # Hero shows stance
	print("hero playing card")
	await _hero.tick_statuses(_villain, _hero)
	print("hero ticked statuses")
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	await _villain.tick_statuses(_villain, _hero)
	print("hero ticked card")
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	await _hero.play_card() # Hero picks random card to play
	if _have_loop_ended.call():
		return
	# on_upkeep effects.
	#phase_ended.emit()
	
