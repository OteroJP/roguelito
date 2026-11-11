class_name VisualCombatAdapter
extends CombatPort

var _combat_manager: CombatManager
var _playing_area: PlayingArea


func _init(combat_manager: CombatManager, playing_area: PlayingArea) -> void:
	_combat_manager = combat_manager
	_playing_area = playing_area
	_combat_manager.card_enabled_state_changed.connect(_sync_card_enabled_state)
	_combat_manager.hero_card_reveal_requested.connect(_reveal_selected_hero_card)
	_sync_card_enabled_state()


func create_state_copy() -> CombatManager:
	return _combat_manager.create_state_copy()


func restore_state_from(source: CombatManager) -> void:
	_combat_manager.restore_state_from(source)


func set_selected_card(combatant_port: CharacterPort, card: CardData) -> void:
	_combat_manager.set_selected_card(combatant_port, card)


func selected_card(combatant_port: CharacterPort) -> CardData:
	return _combat_manager.selected_card(combatant_port)


func clear_selected_cards() -> void:
	_combat_manager.clear_selected_cards()


func present_selected_card(card: CardData, face_up: bool = false) -> void:
	await _playing_area.add_card(card, face_up)
	_sync_card_enabled_state()


func reveal_hero_card() -> void:
	_combat_manager.reveal_hero_card()


func reveal_cards() -> Array[CardData]:
	await _playing_area.reveal_cards()
	return _combat_manager.cards_in_resolution_order()


func discard_presented_card(card: CardData) -> void:
	_playing_area.discard_card(card)


func resolve_card(card: CardData) -> void:
	if _combat_manager.card_is_enabled(card):
		await _playing_area.resolve_card(card)
	await _combat_manager.resolve_card(card)
	await _playing_area.get_tree().create_timer(GameManager.ux_delay).timeout


func clear_resolution_display() -> void:
	await _playing_area.get_tree().create_timer(GameManager.ux_delay).timeout
	await _playing_area.clear()
	_sync_card_enabled_state()


func run_effect_batch(
	configured_effects: Array[Effect],
	effect_owner: CharacterPort,
	report: AuditReport = null
) -> void:
	await _combat_manager.run_effect_batch(configured_effects, effect_owner, report)


func tick_statuses(combatant_port: CharacterPort) -> void:
	await _combat_manager.tick_statuses(combatant_port)


func clear_speed_bonuses() -> void:
	_combat_manager.clear_speed_bonuses()


func _sync_card_enabled_state() -> void:
	_playing_area.set_card_slots_enabled(_combat_manager.card_enabled_state())


func _reveal_selected_hero_card(hero_card: CardData) -> void:
	_playing_area.reveal_card(hero_card)
