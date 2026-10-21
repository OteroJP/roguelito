@abstract class_name CharacterPort extends RefCounted


## Returns a working copy. Commit changes through update_character().
@abstract func get_character() -> Character

## Commits a working copy and synchronizes this character's presentation.
@abstract func update_character(character: Character) -> void

## Plays one card and returns it for phase orchestration.
@abstract func play_card() -> CardData

## Runs the source-side preparation and synchronizes this character's presentation.
func prepare_effect(effect: Effect) -> void:
	var effect_owner := get_character()
	await effect.preparation(effect_owner)
	await update_character(effect_owner)

## Applies an effect to this character and synchronizes its presentation.
func apply_effect(effect: Effect) -> void:
	var target := get_character()
	await effect.apply(target)
	await update_character(target)

## Applies an attack to this character and synchronizes its presentation.
func take_attack(attack: Attack) -> void:
	var target := get_character()
	target.take_attack(attack)
	await update_character(target)

## Prepares this character's presentation before the combat loop starts.
@abstract func prepare_for_combat() -> void

## Performs this character's draw operation through the selected adapter.
@abstract func draw() -> void

## Clears temporary damage immunity on the underlying character.
@abstract func clear_immunity() -> void

## Synchronizes combat-owned status and modifier indicators after an effect.
@abstract func sync_combat_indicators(
	statuses: Array[Status],
	attack_modifiers: Array[AttackModifier],
	speed_bonus: int
) -> void

## Moves a resolved card out of this character's domain deck.
@abstract func discard_played_card(card: CardData) -> void

## Creates execution instances while preserving the configured effect order.
func create_effect_copies(configured_effects: Array[Effect]) -> Array[Effect]:
	var copies: Array[Effect] = []
	for effect: Effect in configured_effects:
		copies.append(effect.create_execution_copy())
	return copies
