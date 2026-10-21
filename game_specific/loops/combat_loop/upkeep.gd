class_name UpkeepLoop extends LoopPhase

var _hero_port: HeroPort
var _villain_port: VillainPort
var _combat_manager: CombatManager


func _init(
	hero_port: HeroPort,
	villain_port: VillainPort,
	combat_manager: CombatManager
	) -> void:
	_hero_port = hero_port
	_villain_port = villain_port
	_combat_manager = combat_manager


func run() -> void:
	start_report()
	_combat_manager.clear_selected_cards()
	await _hero_port.draw() # Hero shows stance
	# here we should expand the report
	await _combat_manager.tick_statuses(_hero_port)
	# here we should expand the report

	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	await _combat_manager.tick_statuses(_villain_port)
	# here we should expand the report
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	var hero_card: HeroCardData = await _hero_port.play_card()
	_combat_manager.set_selected_hero_card(hero_card)
	_report.add("Played a hidden card", AuditLogEntry.Source.HERO)
	await _combat_manager.present_selected_card(hero_card)
	if _have_loop_ended.call():
		return
	#phase_ended.emit()


func get_report() -> AuditReport:
	return _report


func get_audit_header() -> String:
	return "Upkeep starting"
