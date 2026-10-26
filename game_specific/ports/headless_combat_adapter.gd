class_name HeadlessCombatAdapter
extends CombatPort

var _combat_manager: CombatManager


func _init(combat_manager: CombatManager) -> void:
	_combat_manager = combat_manager


func create_state_copy() -> CombatManager:
	return _combat_manager.create_state_copy()


func restore_state_from(source: CombatManager) -> void:
	_combat_manager.restore_state_from(source)


func set_selected_hero_card(card: HeroCardData) -> void:
	_combat_manager.set_selected_hero_card(card)


func set_selected_villain_card(card: VillainCardData) -> void:
	_combat_manager.set_selected_villain_card(card)


func selected_villain_card() -> VillainCardData:
	return _combat_manager.selected_villain_card()


func clear_selected_cards() -> void:
	_combat_manager.clear_selected_cards()


func present_selected_card(_card: CardData, _face_up: bool = false) -> void:
	pass


func reveal_hero_card() -> void:
	pass


func reveal_cards() -> Array[CardData]:
	return _combat_manager.cards_in_resolution_order()


func discard_presented_card(_card: CardData) -> void:
	pass


func resolve_card(card: CardData) -> void:
	await _combat_manager.resolve_card(card)


func clear_resolution_display() -> void:
	pass


func run_effect_batch(
	configured_effects: Array[Effect],
	effect_owner: CharacterPort
) -> void:
	await _combat_manager.run_effect_batch(configured_effects, effect_owner)


func tick_statuses(combatant_port: CharacterPort) -> void:
	await _combat_manager.tick_statuses(combatant_port)


func clear_speed_bonuses() -> void:
	_combat_manager.clear_speed_bonuses()
