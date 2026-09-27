class_name PlayerTurn extends LoopPhase


var _villain: Villain


func _init(
	villain_character, 
	) -> void:
	_villain = villain_character
	
	
func run() -> void:
	GameManager.add_log("Player turn started", GameManager.LogSource.GAME)
	await _villain.draw()
	GameManager.add_log("Villain drawn", GameManager.LogSource.VILLAIN)
	if _have_loop_ended.call():
		return
	GameManager.add_log("Villain may cast spells", GameManager.LogSource.VILLAIN)
	await _villain.cast_spells()
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	GameManager.add_log("Villain plays a card", GameManager.LogSource.VILLAIN)
	await _villain.play_card() # Mandatory: Player selects a card to play, may undo, and the confirms.	
	#phase_ended.emit()	
