class_name Resolution extends LoopPhase

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
	await _resolve_symbol_completion()
	var ordered_cards: Array[CardData] = (
		await _combat_port.reveal_cards()
	)

	for card: CardData in ordered_cards:
		await _combat_port.resolve_card(card)
		# here we should expand the report
		if _have_loop_ended.call():
			_combat_port.clear_selected_cards()
			_combat_port.clear_speed_bonuses()
			return

	for card: CardData in ordered_cards:
		if card is HeroCardData:
			var hero_card := card as HeroCardData
			await _hero_port.change_stance(hero_card.stance_after_clash)
			_hero_port.discard_played_card(hero_card)
		elif card is VillainCardData:
			var villain_card := card as VillainCardData
			_villain_port.set_current_symbol(villain_card.symbol_to_spawn)
			_villain_port.discard_played_card(villain_card)
		_combat_port.discard_presented_card(card)
	_combat_port.clear_selected_cards()

	_hero_port.clear_immunity()
	_villain_port.clear_immunity()
	await _villain_port.discard_over_hand_limit()
	# here we should expand the report
	await _combat_port.clear_resolution_display()
	_combat_port.clear_speed_bonuses()


func get_report() -> AuditReport:
	return _report


func get_audit_header() -> String:
	return "Resolution starting"


func _resolve_symbol_completion() -> void:
	var villain_card := _combat_port.selected_card(_villain_port) as VillainCardData
	if villain_card == null:
		return

	var villain := _villain_port.get_character()
	var symbol := villain_card.symbol_to_complete
	if symbol == Villain.Symbol.NONE or villain.current_symbol != symbol:
		return

	for symbol_bonus: SymbolBonus in villain.symbol_bonuses:
		if symbol_bonus.symbol != symbol:
			continue
		_report.add(
			"Resolves %s bonus effect" % Villain.Symbol.keys()[symbol],
			AuditLogEntry.Source.VILLAIN
		)
		await _combat_port.run_effect_batch(
			symbol_bonus.bonuses,
			_villain_port,
			_report
		)
		# here we should expand the report

	var updated_villain := _villain_port.get_character()
	updated_villain.symbol_count[symbol] += 1
	await _villain_port.update_character(updated_villain)
