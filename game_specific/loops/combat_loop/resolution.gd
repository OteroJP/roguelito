class_name Resolution extends LoopPhase

var _playing_area: Control


func _init(
	playing_area: PlayingArea
	) -> void:
	_playing_area = playing_area


func run() -> void:
	start_report()
	_playing_area.enable_hero_card_visibility(true)
	# check stance and other condicionals.
	# check pc cards condicionales.
	# Compare cards speed and execute in order.
	await GameManager.sort_cards()
	await _playing_area.get_tree().process_frame

	# Execute faster card.
	# WIN-LOSS CHECK
	_report.append(await GameManager.execute_faster_card())
	# Execute slower card.
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return

	_report.append(await GameManager.execute_slower_card())
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return

	_report.append(await GameManager.end_phase())

	await _playing_area.clear()


func get_report() -> AuditReport:
	return _report


func get_audit_header() -> String:
	return "Resolution starting"
