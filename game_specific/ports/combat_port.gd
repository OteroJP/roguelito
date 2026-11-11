@abstract class_name CombatPort
extends RefCounted


@abstract func create_state_copy() -> CombatManager

@abstract func restore_state_from(source: CombatManager) -> void

@abstract func set_selected_card(combatant_port: CharacterPort, card: CardData) -> void

@abstract func selected_card(combatant_port: CharacterPort) -> CardData

@abstract func clear_selected_cards() -> void

@abstract func present_selected_card(card: CardData, face_up: bool = false) -> void

@abstract func reveal_hero_card() -> void

@abstract func reveal_cards() -> Array[CardData]

@abstract func discard_presented_card(card: CardData) -> void

@abstract func resolve_card(card: CardData) -> void

@abstract func clear_resolution_display() -> void

@abstract func run_effect_batch(
	configured_effects: Array[Effect],
	effect_owner: CharacterPort,
	report: AuditReport = null
) -> void

@abstract func tick_statuses(combatant_port: CharacterPort) -> void

@abstract func clear_speed_bonuses() -> void
