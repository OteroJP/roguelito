class_name UpkeepLoop extends LoopPhase

var _hero_port: HeroPort
var _villain_port: VillainPort
var _combat_manager: CombatManager
var _playing_area: PlayingArea


func _init(
	hero_port: HeroPort,
	villain_port: VillainPort,
	combat_manager: CombatManager,
	playing_area: PlayingArea
	) -> void:
	_hero_port = hero_port
	_villain_port = villain_port
	_combat_manager = combat_manager
	_playing_area = playing_area


func run() -> void:
	start_report()
	_report.append(await _hero_port.draw()) # Hero shows stance
	_report.append(await _combat_manager.tick_statuses(_hero_port))

	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	_report.append(await _combat_manager.tick_statuses(_villain_port))
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	await _playing_area.update()
	var hero_card: HeroCardData = await _hero_port.play_card()
	GameManager.current_hero_card = hero_card
	await _playing_area.update()
	await _playing_area.get_tree().create_timer(GameManager.ux_delay).timeout
	_report.add("Played a hidden card", AuditLogEntry.Source.HERO)
	await _playing_area.add_hero_card(GameManager.current_hero_card)
	if _have_loop_ended.call():
		return
	#phase_ended.emit()


func get_report() -> AuditReport:
	return _report


func get_audit_header() -> String:
	return "Upkeep starting"
