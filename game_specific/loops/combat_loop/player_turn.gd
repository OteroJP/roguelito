class_name PlayerTurn extends LoopPhase


var _villain: Villain
var _playing_area: PlayingArea
var _combat_input: CombatInput


func _init(
	villain_character: Villain,
	playing_area: PlayingArea,
	combat_input: CombatInput
	) -> void:
	_villain = villain_character
	_playing_area = playing_area
	_combat_input = combat_input


func run() -> void:
	start_report()
	_report.append(await _villain.draw())
	if _combat_input.reset_requested:
		return
	if _have_loop_ended.call():
		return
	_report.append(await _villain.cast_spells())
	if _combat_input.reset_requested:
		return
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	_report.append(await _villain.play_card()) # Mandatory: Player selects a card to play, may undo, and the confirms.
	if _combat_input.reset_requested:
		return
	await _playing_area.add_villain_card(GameManager.current_villain_card)
	#await _playing_area.get_tree().process_frame


func get_report() -> AuditReport:
	return _report


func get_audit_header() -> String:
	return "Player turn starting"
