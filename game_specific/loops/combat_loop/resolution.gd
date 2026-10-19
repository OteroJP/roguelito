class_name Resolution extends LoopPhase

var _playing_area: PlayingArea
var _hero: HeroPort
var _villain: VillainPort
var _combat_manager: CombatManager


func _init(
	playing_area: PlayingArea,
	hero_port: HeroPort,
	villain_port: VillainPort,
	combat_manager: CombatManager
	) -> void:
	_playing_area = playing_area
	_hero = hero_port
	_villain = villain_port
	_combat_manager = combat_manager


func run() -> void:
	start_report()
	# check stance and other condicionals.
	# check pc cards condicionales.
	# Compare cards speed and execute in order.
	_report.append(await _resolve_symbol_completion())
	await _playing_area.add_villain_card(GameManager.current_villain_card)
	_playing_area.enable_hero_card_visibility(true)
	GameManager.sort_cards(_hero, _villain)
	await _playing_area.get_tree().process_frame

	var cards_by_speed := GameManager.card_resolve_queue.duplicate()
	_report.append(await _resolve_card(cards_by_speed[0], true))
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return

	_report.append(await _resolve_card(cards_by_speed[1], false))
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return

	for card: CardData in cards_by_speed:
		if card is HeroCardData:
			await _hero.change_stance(card.stance_after_clash)
			_hero.discard_played_card(card)
		elif card is VillainCardData:
			_villain.set_current_symbol(card.symbol_to_spawn)
			_villain.discard_played_card(card)

	_hero.clear_immunity()
	GameManager.is_current_hero_card_enabled = true
	GameManager.is_current_villain_card_enabled = true
	_combat_manager.clear_round_modifiers()
	_sync_combat_indicators(_hero)
	_sync_combat_indicators(_villain)
	_report.append(await _villain.discard_over_hand_limit())
	await _playing_area.get_tree().create_timer(GameManager.ux_delay).timeout

	await _playing_area.clear()


func _sync_combat_indicators(combatant_port: CharacterPort) -> void:
	combatant_port.sync_combat_indicators(
		_combat_manager.statuses_for(combatant_port),
		_combat_manager.attack_modifiers_for(combatant_port),
		_combat_manager.speed_bonus_for(combatant_port)
	)


func _resolve_card(card: CardData, is_faster_card: bool) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var source := _source_for(card)
	outcome.add(AuditEvent.Kind.CARD_RESOLUTION_SEPARATOR, AuditLogEntry.Source.GAME)
	if not _card_is_enabled(card):
		if is_faster_card:
			outcome.add(AuditEvent.Kind.CARD_SKIPPED, source, 0, "", "", true)
		else:
			outcome.add(AuditEvent.Kind.CARD_SKIPPED, source)
	else:
		outcome.add(AuditEvent.Kind.CARD_RESOLVING, source, 0, card.name)
		if card is HeroCardData:
			await _playing_area.resolve_hero_card()
		else:
			await _playing_area.resolve_villain_card()
		outcome.append(await _resolve_card_effects(card))
	await _playing_area.update()
	await _playing_area.get_tree().create_timer(GameManager.ux_delay).timeout
	return outcome


func _resolve_card_effects(card: CardData) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if card is HeroCardData:
		var hero_card := card as HeroCardData
		var hero := _hero.get_character()
		if hero.is_in_stance(hero_card.stance_for_bonus):
			outcome.add(AuditEvent.Kind.STANCE_BONUS_TRIGGERED, AuditLogEntry.Source.HERO)
			outcome.append(await _run_card_effect_batch(_hero, hero_card.bonus_effects))
		outcome.append(await _run_card_effect_batch(_hero, hero_card.effects))
	elif card is VillainCardData:
		var villain_card := card as VillainCardData
		var villain := _villain.get_character()
		if villain.is_in_second_phase():
			outcome.add(AuditEvent.Kind.SECOND_PHASE_BONUS_TRIGGERED, AuditLogEntry.Source.VILLAIN)
			outcome.append(await _run_card_effect_batch(_villain, villain_card.bonus_effects))
		outcome.append(await _run_card_effect_batch(_villain, villain_card.effects))
	return outcome


func _resolve_symbol_completion() -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var villain_card := GameManager.current_villain_card
	if villain_card == null:
		return outcome

	var villain := _villain.get_character()
	var symbol := villain_card.symbol_to_complete
	if symbol == Villain.Symbol.NONE or villain.current_symbol != symbol:
		return outcome

	for symbol_bonus: SymbolBonus in villain.symbol_bonuses:
		if symbol_bonus.symbol != symbol:
			continue
		outcome.add(
			AuditEvent.Kind.SYMBOL_BONUS_RESOLVED,
			AuditLogEntry.Source.VILLAIN,
			0,
			Villain.Symbol.keys()[symbol]
		)
		outcome.append(await _run_card_effect_batch(_villain, symbol_bonus.bonuses))

	var updated_villain := _villain.get_character()
	updated_villain.symbol_count[symbol] += 1
	await _villain.update_character(updated_villain)
	return outcome


func _run_card_effect_batch(
	owner_port: CharacterPort,
	configured_effects: Array[Effect]
) -> AuditOutcome:
	var effect_copies := owner_port.create_effect_copies(configured_effects)
	return await _combat_manager.run_effect_copies(effect_copies, _villain, _hero)


func _card_is_enabled(card: CardData) -> bool:
	if card is HeroCardData:
		return GameManager.current_hero_card_enabled()
	return GameManager.current_villain_card_enabled()


func _source_for(card: CardData) -> AuditLogEntry.Source:
	if card is HeroCardData:
		return AuditLogEntry.Source.HERO
	return AuditLogEntry.Source.VILLAIN


func get_report() -> AuditReport:
	return _report


func get_audit_header() -> String:
	return "Resolution starting"
