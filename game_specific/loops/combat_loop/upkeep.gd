class_name UpkeepLoop extends LoopPhase

var _hero: Hero
var _hero_port: HeroPort
var _villain: Villain
var _combat_manager: CombatManager
var _playing_area: PlayingArea


func _init(
	hero_port: HeroPort,
	hero_character: Hero,
	villain_character: Villain,
	combat_manager: CombatManager,
	playing_area: PlayingArea
	) -> void:
	_hero_port = hero_port
	_hero = hero_character
	_villain = villain_character
	_combat_manager = combat_manager
	_playing_area = playing_area


func run() -> void:
	start_report()
	_report.append(await _hero_port.draw()) # Hero shows stance
	# Status ticking moves to CombatManager in a later refactor step.
	# _report.append(await _combat_manager.tick_statuses(_hero))

	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	# _report.append(await _combat_manager.tick_statuses(_villain))
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	await _playing_area.update()
	_report.append(await _hero_port.play_card()) # Hero picks random card to play
	_report.add("Played a hidden card", AuditLogEntry.Source.HERO)
	await _playing_area.add_hero_card(GameManager.current_hero_card)
	if _have_loop_ended.call():
		return
	#phase_ended.emit()


func get_report() -> AuditReport:
	return _report


func get_audit_header() -> String:
	return "Upkeep starting"
