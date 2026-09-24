extends Node

var villain: Villain
var hero: Hero
var current_villain_card: VillainCardData
var current_hero_card: HeroCardData
var card_resolve_queue: Array[CardData]
var ux_delay: float


func sort_cards() -> void:
	card_resolve_queue = _sort_cards_by_fastest(current_hero_card, current_villain_card)	
	

func play_villain_card(card: VillainCardData) -> void:
	current_villain_card = card
	card.on_play(villain, hero)
	await get_tree().create_timer(GameManager.ux_delay).timeout


func play_hero_card(card: HeroCardData) -> void:
	current_hero_card = card
	card.on_play(villain, hero)
	await get_tree().create_timer(GameManager.ux_delay).timeout


func execute_faster_card() -> void:
	card_resolve_queue[0].on_clash(villain, hero)
	await get_tree().create_timer(GameManager.ux_delay).timeout


func execute_slower_card() -> void:
	card_resolve_queue[1].on_clash(villain, hero)
	await get_tree().create_timer(GameManager.ux_delay).timeout
	
	
func end_phase() -> void:
	for card in card_resolve_queue:
		card.after_clash(villain, hero)
	await get_tree().create_timer(GameManager.ux_delay).timeout


func _sort_cards_by_fastest(card_a: CardData, card_b: CardData) -> Array[CardData]:
	var sorted_cards: Array[CardData]
	if card_a.speed > card_b.speed:
		sorted_cards = [card_a, card_b]
	else:
		sorted_cards = [card_b, card_a]
	return sorted_cards
