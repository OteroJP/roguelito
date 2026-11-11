@abstract class_name CharacterPort extends RefCounted


## Returns a working copy. Commit changes through update_character().
@abstract func get_character() -> Character

## Commits a working copy and synchronizes this character's presentation.
@abstract func update_character(character: Character) -> void

## Plays one card and returns it for phase orchestration.
@abstract func play_card() -> CardData

## Applies an effect and synchronizes presentation if its character data changed.
@abstract func apply_effect(effect: Effect) -> void

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



## Applies an attack to this character and synchronizes its presentation.
func take_attack(attack: Attack) -> void:
	var target := get_character()
	target.take_attack(attack)
	await update_character(target)


## Starts effect preparation. Preparation is read-only; it must not mutate character state.
func prepare_effect(effect: Effect) -> void:
	await effect.prepare(self)
