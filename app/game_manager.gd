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
	match card_resolve_queue[0].get_class():
		"HeroCardData":
			if is_current_hero_card_enabled: card_resolve_queue[0].on_clash(villain, hero)
		"VillainCardData":
			if is_current_villain_card_enabled: card_resolve_queue[0].on_clash(villain, hero)			
	await get_tree().create_timer(GameManager.ux_delay).timeout


func execute_slower_card() -> void:
	match card_resolve_queue[0].get_class():
		"HeroCardData":
			if is_current_hero_card_enabled: card_resolve_queue[0].on_clash(villain, hero)
		"VillainCardData":
			if is_current_villain_card_enabled: card_resolve_queue[0].on_clash(villain, hero)			
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
