extends Node

signal all_cards_resolved

var villain: Character
var hero: Character
var current_villain_card: CardData
var current_hero_card: CardData
var card_resolve_queue: Array[CardData]
var ux_delay: float


func sort_cards() -> void:
	card_resolve_queue = _sort_cards_by_fastest(current_hero_card, current_villain_card)	
	

func execute_faster_card() -> void:
	for effect in card_resolve_queue[0].effects:
		_resolve_card_effect(effect) #await 
	await get_tree().create_timer(GameManager.ux_delay).timeout


func execute_slower_card() -> void:
	for effect in card_resolve_queue[1].effects:
		_resolve_card_effect(effect) #await
	await get_tree().create_timer(GameManager.ux_delay).timeout
	
	
func end_phase() -> void:
	for card in card_resolve_queue:
		card.resolved.emit(card)
	await get_tree().create_timer(GameManager.ux_delay).timeout


func _sort_cards_by_fastest(card_a: CardData, card_b: CardData) -> Array[CardData]:
	var sorted_cards: Array[CardData]
	if card_a.speed > card_b.speed:
		sorted_cards = [card_a, card_b]
	else:
		sorted_cards = [card_b, card_a]
	return sorted_cards


func _resolve_card_effect(effect: CardEffect) -> void:
	var effect_to_resolve: CardEffect = effect.duplicate(true)
	match effect_to_resolve._target:
		CardEffect.Target.VILLAIN:
			effect_to_resolve.character_target = villain
		CardEffect.Target.HERO:
			effect_to_resolve.character_target = hero
		CardEffect.Target.NONE:
			#TODO
			pass
		CardEffect.Target.BOTH:
			#TODO
			pass
		CardEffect.Target.CARD:
			#TODO
			pass
		_:
			#TODO
			pass
	effect_to_resolve.on_resolve()
