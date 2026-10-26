class_name PlayerTurn extends LoopPhase


var _villain: VillainPort
var _hero: HeroPort
var _combat_port: CombatPort


func _init(
	villain_port: VillainPort,
	hero_port: HeroPort,
	combat_port: CombatPort
	) -> void:
	_villain = villain_port
	_hero = hero_port
	_combat_port = combat_port


func run() -> void:
	start_report()
	await _villain.draw()
	# here we should expand the report
	# if _combat_input.reset_requested:
	#	return
	if _have_loop_ended.call():
		return
	# _villain.begin_spell_selection()
	# while not _villain.spells_chosen():
	#	var spell: VillainSpell = await _villain.choose_spell()
	#	if spell == null:
	#		if _combat_input.reset_requested:
	#			return
	#		continue
	#	# here we should expand the report
	#	if _combat_input.reset_requested:
	#		return
	#	if _have_loop_ended.call():
	#		_villain.finish_spell_selection()
	#		break
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	var villain_card: VillainCardData = await _villain.play_card()
	# if _combat_input.reset_requested:
	#	return
	if villain_card == null:
		return
	_combat_port.set_selected_villain_card(villain_card)
	await _combat_port.present_selected_card(villain_card)
	_report.add("Played %s" % villain_card.name, AuditLogEntry.Source.VILLAIN)


func get_report() -> AuditReport:
	return _report


func get_audit_header() -> String:
	return "Player turn starting"
