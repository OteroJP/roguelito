class_name PlayerTurn extends LoopPhase


var _villain: Villain


func _init(
	villain_character, 
	) -> void:
	_villain = villain_character
	
	
func run() -> void:
	print("player turn started")
	await _villain.draw()
	print("villain drawn")
	if _have_loop_ended.call():
		return
	await _villain.activate_ability() 
	# TODO: cambiar lo de abajo por esto? 
	#		> GameManager.current_hero_card = await _villain.play_card() 
	await _villain.play_card() # Mandatory: Player selects a card to play, may undo, and the confirms.	
	#phase_ended.emit()	
