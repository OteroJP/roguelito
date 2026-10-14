class_name PlayerTurn extends LoopPhase


var _villain: VillainPort
var _hero: HeroPort
var _combat_manager: CombatManager
var _playing_area: PlayingArea
var _combat_input: CombatInput


func _init(
	villain_port: VillainPort,
	hero_port: HeroPort,
	combat_manager: CombatManager,
	playing_area: PlayingArea,
	combat_input: CombatInput
	) -> void:
	_villain = villain_port
	_hero = hero_port
	_combat_manager = combat_manager
	_playing_area = playing_area
	_combat_input = combat_input


func run() -> void:
	start_report()
	_report.append(await _villain.draw())
	if _combat_input.reset_requested:
		return
	if _have_loop_ended.call():
		return
	_villain.begin_spell_selection()
	while not _villain.spells_chosen():
		var spell: VillainSpell = await _villain.choose_spell()
		if spell == null:
			if _combat_input.reset_requested:
				return
			continue
		_report.append(
			await _combat_manager.run_effect_batch(spell.effects, _villain, _hero)
		)
		if _combat_input.reset_requested:
			return
		if _have_loop_ended.call():
			_villain.finish_spell_selection()
			break
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
