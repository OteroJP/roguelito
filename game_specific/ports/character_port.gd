@abstract class_name CharacterPort extends RefCounted


## Returns a working copy. Commit changes through update_character().
@abstract func get_character() -> Character

## Prepares this character's presentation before the combat loop starts.
@abstract func prepare_for_combat() -> void

## Performs this character's draw operation through the selected adapter.
@abstract func draw() -> AuditOutcome

## Synchronizes combat-owned status and modifier indicators after an effect.
@abstract func sync_combat_indicators(
	statuses: Array[Status],
	attack_modifiers: Array[AttackModifier],
	speed_bonus: int
) -> void

## Moves a resolved card out of both the domain and visual playing areas.
@abstract func discard_played_card(card: CardData) -> void


## Creates execution instances while preserving the configured effect order.
func create_effect_copies(configured_effects: Array[Effect]) -> Array[Effect]:
	var copies: Array[Effect] = []
	for effect: Effect in configured_effects:
		copies.append(effect.create_execution_copy())
	return copies
