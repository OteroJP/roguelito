class_name UpkeepLoop extends LoopPhase

var _hero_port: HeroPort
var _villain_port: VillainPort
var _combat_port: CombatPort


func _init(
	villain_port: VillainPort,
	hero_port: HeroPort,
	combat_port: CombatPort
	) -> void:
	_hero_port = hero_port
	_villain_port = villain_port
	_combat_port = combat_port


func run() -> void:
	start_report()
	_combat_port.clear_selected_cards()
	await _hero_port.draw() # Hero shows stance
	# here we should expand the report
	await _combat_port.tick_statuses(_hero_port)
	# here we should expand the report

	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	await _combat_port.tick_statuses(_villain_port)
	# here we should expand the report
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	var hero_card: HeroCardData = await _hero_port.play_card()
	_combat_port.set_selected_card(_hero_port, hero_card)
	_report.add("Played a hidden card", AuditLogEntry.Source.HERO)
	await _combat_port.present_selected_card(hero_card)
	if _have_loop_ended.call():
		return
	#phase_ended.emit()


func get_report() -> AuditReport:
	return _report


func get_audit_header() -> String:
	return "Upkeep starting"
