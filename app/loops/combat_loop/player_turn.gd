class_name PlayerTurn extends LoopPhase


var _villain: Villain
var _playing_area: PlayingArea


func _init(
	villain_character: Villain,
	playing_area: PlayingArea
	) -> void:
	_villain = villain_character
	_playing_area = playing_area
	
	
func run() -> void:
	GameManager.add_debug("Player turn started", GameManager.LogSource.GAME)
	await _villain.draw()
	GameManager.add_debug("Villain drawn", GameManager.LogSource.VILLAIN)
	if _have_loop_ended.call():
		return
	GameManager.add_debug("Villain may cast spells", GameManager.LogSource.VILLAIN)
	await _villain.cast_spells()
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	GameManager.add_debug("Villain plays a card", GameManager.LogSource.VILLAIN)
	await _villain.play_card() # Mandatory: Player selects a card to play, may undo, and the confirms.	
	await _playing_area.add_villain_card(GameManager.current_villain_card)
	#await _playing_area.get_tree().process_frame 
