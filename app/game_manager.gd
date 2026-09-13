extends Node

signal all_cards_resolved

var villain: Character
var hero: Character
var current_villain_card: Card
var current_hero_card: Card
var card_resolve_queue: Array[Card]

func _resolve_clash() -> void:
	if not current_hero_card or not current_villain_card:
		push_error("Villain's or hero's card not found.")
		return
		#This wouldn't trigger the await, thus freezing the game
	card_resolve_queue = _sort_cards_by_fastest(current_hero_card, current_villain_card)
	for card in card_resolve_queue:
		for effect in card.data.effects:
			_resolve_card_effect(effect)
	all_cards_resolved.emit()
	

func _sort_cards_by_fastest(card_a: Card, card_b: Card) -> Array[Card]:
	return [card_a, card_b] if card_a._data.speed > card_b._data.speed else [card_b, card_a]


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
