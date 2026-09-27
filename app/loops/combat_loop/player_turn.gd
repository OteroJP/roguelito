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
	await _villain.activate_ability() 
	# TODO: cambiar lo de abajo por esto? 
	#		> GameManager.current_hero_card = await _villain.play_card() 
	await _villain.play_card() # Mandatory: Player selects a card to play, may undo, and the confirms.	
	#phase_ended.emit()	
