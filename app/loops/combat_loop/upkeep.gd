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
	GameManager.add_log("Upkeep started", GameManager.LogSource.GAME)
	await _hero.draw() # Hero shows stance
	GameManager.add_log("Hero chose card", GameManager.LogSource.HERO)
	await _hero.tick_statuses(_villain, _hero)
	GameManager.add_log("Hero ticked statuses", GameManager.LogSource.HERO)
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	await _villain.tick_statuses(_villain, _hero)
	GameManager.add_log("Villain ticked statuses", GameManager.LogSource.VILLAIN)
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	await _hero.play_card() # Hero picks random card to play
	if _have_loop_ended.call():
		return
	#phase_ended.emit()
	
