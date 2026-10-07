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


func sort_cards() -> void:
	card_resolve_queue = _sort_cards_by_fastest()	
	

func play_villain_card(card: VillainCardData) -> void:
	current_villain_card = card
	card.on_play(villain, hero)
	await playing_area.update()
	await get_tree().create_timer(GameManager.ux_delay).timeout


func play_hero_card(card: HeroCardData) -> void:
	current_hero_card = card
	card.on_play(villain, hero)
	await playing_area.update()
	await get_tree().create_timer(GameManager.ux_delay).timeout


func execute_faster_card() -> void:
	#TODO this could be cleaner
	if (card_resolve_queue[0] == current_villain_card):
		villain.audit_report.add("------------------", AuditLogEntry.Source.VILLAIN)
		if current_villain_card_enabled():
			villain.audit_report.add("Resolve %s" % current_villain_card.name, AuditLogEntry.Source.VILLAIN)
			await playing_area.resolve_villain_card()
			await current_villain_card.on_clash(villain, hero)
		else:
			villain.audit_report.add("CANCELLED!:", AuditLogEntry.Source.VILLAIN)
	if (card_resolve_queue[0] == current_hero_card):
		hero.audit_report.add("------------------", AuditLogEntry.Source.HERO)
		if current_hero_card_enabled():
			hero.audit_report.add("Resolve %s" % current_hero_card.name, AuditLogEntry.Source.HERO)
			await playing_area.resolve_hero_card()
			await current_hero_card.on_clash(villain, hero)
		else:
			hero.audit_report.add("CANCELLED!:", AuditLogEntry.Source.HERO)
	await playing_area.update()
	await get_tree().create_timer(GameManager.ux_delay).timeout


func execute_slower_card() -> void:
	#TODO this could be cleaner
	if (card_resolve_queue[1] == current_villain_card):
		villain.audit_report.add("------------------", AuditLogEntry.Source.VILLAIN)
		if is_current_villain_card_enabled:
			villain.audit_report.add("Resolve %s" % current_villain_card.name, AuditLogEntry.Source.VILLAIN)
			await playing_area.resolve_villain_card()
			await current_villain_card.on_clash(villain, hero)
		else:
			villain.audit_report.add("CANCELLED!", AuditLogEntry.Source.VILLAIN)
	if (card_resolve_queue[1] == current_hero_card):
		hero.audit_report.add("------------------", AuditLogEntry.Source.HERO)
		if is_current_hero_card_enabled:
			hero.audit_report.add("Resolve %s" % current_hero_card.name, AuditLogEntry.Source.HERO)
			await playing_area.resolve_hero_card()
			await current_hero_card.on_clash(villain, hero)
		else:
			hero.audit_report.add("CANCELLED!", AuditLogEntry.Source.HERO)
	await playing_area.update()
	await get_tree().create_timer(GameManager.ux_delay).timeout
	
	
func end_phase() -> void:
	for card in card_resolve_queue:
		card.after_clash(villain, hero)
	hero.end_phase()
	await villain.end_phase()
	await get_tree().create_timer(GameManager.ux_delay).timeout


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
