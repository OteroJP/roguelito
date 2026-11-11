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
	# TODO: expand the report, have player taken damage? draw should tell
	# _report.add("Played %s" % villain_card.name, AuditLogEntry.Source.VILLAIN)
	while not _have_loop_ended.call():
		var spell: VillainSpell = await _villain.choose_spell()
		if spell == null:
			# TODO: expand the report, player will select no more spells
			# _report.add("Player pass to card selection", AuditLogEntry.Source.VILLAIN)
			break
		var spell_effects: Array[Effect] = _villain.cast_spell(spell)
		await _combat_port.run_effect_batch(spell_effects, _villain, _report)
		# here we should expand the report
	if not _have_loop_ended.call(): 
		var villain_card: VillainCardData = await _villain.play_card()
		_combat_port.set_selected_card(_villain, villain_card)
		await _combat_port.present_selected_card(villain_card)
		_report.add("Played %s" % villain_card.name, AuditLogEntry.Source.VILLAIN)


func get_report() -> AuditReport:
	return _report


func get_audit_header() -> String:
	return "Player turn starting"
