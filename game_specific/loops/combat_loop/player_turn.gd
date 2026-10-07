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
	await _villain.draw()
	if _have_loop_ended.call():
		return
	await _villain.cast_spells()
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	await _villain.play_card() # Mandatory: Player selects a card to play, may undo, and the confirms.	
	await _playing_area.add_villain_card(GameManager.current_villain_card)
	#await _playing_area.get_tree().process_frame 


func get_report() -> AuditReport:
	return _report
