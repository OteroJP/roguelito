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
	start_report()
	_report.append(await _hero.draw()) # Hero shows stance
	_report.append(await _hero.tick_statuses(_villain, _hero))

	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	_report.append(await _villain.tick_statuses(_villain, _hero))
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	await _playing_area.update()
	_report.append(await _hero.play_card()) # Hero picks random card to play
	_report.add("Played a hidden card", AuditLogEntry.Source.HERO)
	await _playing_area.add_hero_card(GameManager.current_hero_card)
	if _have_loop_ended.call():
		return
	#phase_ended.emit()


func get_report() -> AuditReport:
	return _report


func get_audit_header() -> String:
	return "Upkeep starting"
