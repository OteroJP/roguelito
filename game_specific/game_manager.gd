extends Node

var villain: Villain
var hero: Hero
#TODO These should be tuples?
var current_villain_card: VillainCardData
var is_current_villain_card_enabled: bool = true
var current_hero_card: HeroCardData
var is_current_hero_card_enabled: bool = true
var card_resolve_queue: Array[CardData]
var playing_area: PlayingArea
var ux_delay: float


func prepare(_playing_area: PlayingArea, _hero: Hero, _villain: Villain, _ux_delay: float) -> void:
	playing_area = _playing_area
	hero = _hero
	villain = _villain
	ux_delay = _ux_delay


func save_turn_state() -> Dictionary:
	return {
		"current_villain_card": current_villain_card,
		"is_current_villain_card_enabled": is_current_villain_card_enabled,
		"current_hero_card": current_hero_card,
		"is_current_hero_card_enabled": is_current_hero_card_enabled,
		"card_resolve_queue": card_resolve_queue.duplicate(),
	}


func restore_turn_state(state: Dictionary) -> void:
	current_villain_card = state["current_villain_card"]
	is_current_villain_card_enabled = state["is_current_villain_card_enabled"]
	current_hero_card = state["current_hero_card"]
	is_current_hero_card_enabled = state["is_current_hero_card_enabled"]
	card_resolve_queue = state["card_resolve_queue"].duplicate()


func sort_cards() -> void:
	card_resolve_queue = _sort_cards_by_fastest()


func play_villain_card(card: VillainCardData) -> AuditOutcome:
	current_villain_card = card
	var outcome := await card.on_play(villain, hero)
	await playing_area.update()
	await get_tree().create_timer(GameManager.ux_delay).timeout
	return outcome


func play_hero_card(card: HeroCardData) -> AuditOutcome:
	current_hero_card = card
	var outcome := await card.on_play(villain, hero)
	await playing_area.update()
	await get_tree().create_timer(GameManager.ux_delay).timeout
	return outcome


func execute_faster_card() -> AuditOutcome:
	var outcome := AuditOutcome.new()
	#TODO this could be cleaner
	if (card_resolve_queue[0] == current_villain_card):
		outcome.add(AuditEvent.Kind.CARD_RESOLUTION_SEPARATOR, AuditLogEntry.Source.GAME)
		if current_villain_card_enabled():
			outcome.add(AuditEvent.Kind.CARD_RESOLVING, AuditLogEntry.Source.VILLAIN, 0, current_villain_card.name)
			await playing_area.resolve_villain_card()
			outcome.append(await current_villain_card.on_clash(villain, hero))
		else:
			outcome.add(AuditEvent.Kind.CARD_SKIPPED, AuditLogEntry.Source.VILLAIN, 0, "", "", true)
	if (card_resolve_queue[0] == current_hero_card):
		outcome.add(AuditEvent.Kind.CARD_RESOLUTION_SEPARATOR, AuditLogEntry.Source.GAME)
		if current_hero_card_enabled():
			outcome.add(AuditEvent.Kind.CARD_RESOLVING, AuditLogEntry.Source.HERO, 0, current_hero_card.name)
			await playing_area.resolve_hero_card()
			outcome.append(await current_hero_card.on_clash(villain, hero))
		else:
			outcome.add(AuditEvent.Kind.CARD_SKIPPED, AuditLogEntry.Source.HERO, 0, "", "", true)
	await playing_area.update()
	await get_tree().create_timer(GameManager.ux_delay).timeout
	return outcome


func execute_slower_card() -> AuditOutcome:
	var outcome := AuditOutcome.new()
	#TODO this could be cleaner
	if (card_resolve_queue[1] == current_villain_card):
		outcome.add(AuditEvent.Kind.CARD_RESOLUTION_SEPARATOR, AuditLogEntry.Source.GAME)
		if is_current_villain_card_enabled:
			outcome.add(AuditEvent.Kind.CARD_RESOLVING, AuditLogEntry.Source.VILLAIN, 0, current_villain_card.name)
			await playing_area.resolve_villain_card()
			outcome.append(await current_villain_card.on_clash(villain, hero))
		else:
			outcome.add(AuditEvent.Kind.CARD_SKIPPED, AuditLogEntry.Source.VILLAIN)
	if (card_resolve_queue[1] == current_hero_card):
		outcome.add(AuditEvent.Kind.CARD_RESOLUTION_SEPARATOR, AuditLogEntry.Source.GAME)
		if is_current_hero_card_enabled:
			outcome.add(AuditEvent.Kind.CARD_RESOLVING, AuditLogEntry.Source.HERO, 0, current_hero_card.name)
			await playing_area.resolve_hero_card()
			outcome.append(await current_hero_card.on_clash(villain, hero))
		else:
			outcome.add(AuditEvent.Kind.CARD_SKIPPED, AuditLogEntry.Source.HERO)
	await playing_area.update()
	await get_tree().create_timer(GameManager.ux_delay).timeout
	return outcome


func end_phase() -> AuditOutcome:
	var outcome := AuditOutcome.new()
	for card in card_resolve_queue:
		outcome.append(await card.after_clash(villain, hero))
	outcome.append(hero.end_phase())
	outcome.append(await villain.end_phase())
	await get_tree().create_timer(GameManager.ux_delay).timeout
	return outcome


func _sort_cards_by_fastest() -> Array[CardData]:
	var sorted_cards: Array[CardData]
	if (current_hero_card.speed + hero.speed_bonus) > (current_villain_card.speed + villain.speed_bonus):
		sorted_cards = [current_hero_card, current_villain_card]
	else:
		sorted_cards = [current_villain_card, current_hero_card]
	return sorted_cards


func current_villain_card_enabled() -> bool:
	return is_current_villain_card_enabled


func current_hero_card_enabled() -> bool:
	return is_current_hero_card_enabled
