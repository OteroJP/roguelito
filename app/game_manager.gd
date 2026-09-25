extends Node

var villain: Villain
var hero: Hero
#TODO These should be tuples?
var current_villain_card: VillainCardData
var is_current_villain_card_enabled: bool = true
var current_hero_card: HeroCardData
var is_current_hero_card_enabled: bool = true
var card_resolve_queue: Array[CardData]
var ux_delay: float
var log: Label


func sort_cards() -> void:
	card_resolve_queue = _sort_cards_by_fastest()	
	

func play_villain_card(card: VillainCardData) -> void:
	current_villain_card = card
	card.on_play(villain, hero)
	await get_tree().create_timer(GameManager.ux_delay).timeout


func play_hero_card(card: HeroCardData) -> void:
	current_hero_card = card
	card.on_play(villain, hero)
	await get_tree().create_timer(GameManager.ux_delay).timeout


func execute_faster_card() -> void:
	#TODO this could be cleaner
	if (card_resolve_queue[0] == current_villain_card):
		if is_current_villain_card_enabled:
			GameManager.add_log("VILLAIN GOES FIRST:")
			card_resolve_queue[0].on_clash(villain, hero)
		else:
			GameManager.add_log("VILLAIN WAS CANCELLED!:")
	if (card_resolve_queue[0] == current_hero_card):
		if is_current_hero_card_enabled:
			GameManager.add_log("HERO GOES FIRST:")
			card_resolve_queue[0].on_clash(villain, hero)
		else:
			GameManager.add_log("HERO WAS CANCELLED!:")
	await get_tree().create_timer(GameManager.ux_delay).timeout


func execute_slower_card() -> void:
	#TODO this could be cleaner
	if (card_resolve_queue[1] == current_villain_card):
		if is_current_villain_card_enabled:
			GameManager.add_log("VILLAIN GOES SECOND:")
			card_resolve_queue[1].on_clash(villain, hero)
		else:
			GameManager.add_log("VILLAIN WAS CANCELLED!")
	if (card_resolve_queue[1] == current_hero_card):
		if is_current_hero_card_enabled:
			GameManager.add_log("HERO GOES SECOND:")
			card_resolve_queue[1].on_clash(villain, hero)
		else:
			GameManager.add_log("HERO WAS CANCELLED!")
	await get_tree().create_timer(GameManager.ux_delay).timeout
	
	
func end_phase() -> void:
	for card in card_resolve_queue:
		card.after_clash(villain, hero)
	hero.end_phase()
	villain.end_phase()
	await get_tree().create_timer(GameManager.ux_delay).timeout


func _sort_cards_by_fastest() -> Array[CardData]:
	var sorted_cards: Array[CardData]
	if (current_hero_card.speed + hero.speed_bonus) > (current_villain_card.speed + villain.speed_bonus):
		sorted_cards = [current_hero_card, current_villain_card]
	else:
		sorted_cards = [current_villain_card, current_hero_card]
	return sorted_cards


func clear_log() -> void:
	log.text = ""


func add_log(line: String) -> void:
	log.text += "\n" + line
	await get_tree().process_frame
	var scroll := log.get_parent() as ScrollContainer
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
