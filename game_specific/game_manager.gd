extends Node

var combat_manager: CombatManager
#TODO These should be tuples?
var current_villain_card: VillainCardData
var is_current_villain_card_enabled: bool = true
var current_hero_card: HeroCardData
var is_current_hero_card_enabled: bool = true
var card_resolve_queue: Array[CardData]
var ux_delay: float


func prepare(
	_ux_delay: float,
	_combat_manager: CombatManager
) -> void:
	ux_delay = _ux_delay
	combat_manager = _combat_manager


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


func sort_cards(hero_port: HeroPort, villain_port: VillainPort) -> void:
	card_resolve_queue = _sort_cards_by_fastest(hero_port, villain_port)


func _sort_cards_by_fastest(
	hero_port: HeroPort,
	villain_port: VillainPort
) -> Array[CardData]:
	var sorted_cards: Array[CardData]
	if (
		current_hero_card.speed + combat_manager.speed_bonus_for(hero_port)
		> current_villain_card.speed + combat_manager.speed_bonus_for(villain_port)
	):
		sorted_cards = [current_hero_card, current_villain_card]
	else:
		sorted_cards = [current_villain_card, current_hero_card]
	return sorted_cards


func current_villain_card_enabled() -> bool:
	return is_current_villain_card_enabled


func current_hero_card_enabled() -> bool:
	return is_current_hero_card_enabled
