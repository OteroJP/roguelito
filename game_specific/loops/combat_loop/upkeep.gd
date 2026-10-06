class_name UpkeepLoop extends LoopPhase
	
var _hero: Hero
var _villain: Villain
var _playing_area: PlayingArea

func _init(
	hero_character: Hero,
	villain_character: Villain,
	playing_area: PlayingArea
	) -> void:
	_hero = hero_character
	_villain = villain_character
	_playing_area = playing_area

	
func run() -> void:
	GameManager.add_debug("---------------------------------------------------------", GameManager.LogSource.GAME)
	await _hero.draw() # Hero shows stance
	await _hero.tick_statuses(_villain, _hero)

	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	await _villain.tick_statuses(_villain, _hero)
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	await _playing_area.update()
	await _hero.play_card() # Hero picks random card to play
	GameManager.add_debug("Played a hidden card", GameManager.LogSource.HERO)
	await _playing_area.add_hero_card(GameManager.current_hero_card)
	if _have_loop_ended.call():
		return
	#phase_ended.emit()
	
