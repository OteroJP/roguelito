extends Node

signal all_cards_resolved

var villain: Character
var hero: Character
var current_villain_card: CardData
var current_hero_card: CardData
var card_resolve_queue: Array[Card]


func sort_cards() -> void:
	card_resolve_queue = _sort_cards_by_fastest(current_hero_card, current_villain_card)	
	

func execute_faster_card() -> void:
	for effect in card_resolve_queue[0].data.effects:
		_resolve_card_effect(effect) #await 
	await get_tree().process_frame


func execute_slower_card() -> void:
	for effect in card_resolve_queue[1].data.effects:
		_resolve_card_effect(effect) #await 
	await get_tree().process_frame
	
	
func end_phase() -> void:
	for card in card_resolve_queue:
		card.resolved.emit()
	await get_tree().process_frame


func _sort_cards_by_fastest(card_a: CardData, card_b: CardData) -> Array[Card]:
	return [card_a, card_b] if card_a.speed > card_b.speed else [card_b, card_a]


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

	
func _resolve_clash() -> void:
	if not current_hero_card or not current_villain_card:
		push_error("Villain's or hero's card not found.")
		return
		#This wouldn't trigger the await, thus freezing the game
	sort_cards()
	for card in card_resolve_queue:
		for effect in card.data.effects:
			_resolve_card_effect(effect) #await 
	all_cards_resolved.emit()
