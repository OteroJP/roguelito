@abstract class_name VillainPort extends RefCounted


## Returns a working copy. Commit changes through update_character().
@abstract func get_character() -> Villain

## Commits a working copy to the underlying character.
@abstract func update_character(character: Villain) -> void

## Performs the Villain's draw operation through the selected adapter.
@abstract func draw() -> AuditOutcome

## Lets the player or headless adapter choose a spell and resolves the spell phase.
@abstract func cast_spells() -> AuditOutcome

## Lets the player or headless adapter choose a card and plays it.
@abstract func play_card() -> AuditOutcome

## Requests a selection from the Villain's hand.
@abstract func choose_cards_from_hand(amount: int) -> Array[CardData]

## Requests a selection from the supplied discard-pile cards.
@abstract func choose_cards_from_discard(cards: Array[CardData], amount: int) -> Array[CardData]

## Selects and discards cards from the Villain's hand at the end of a phase.
@abstract func end_phase() -> AuditOutcome

## Lets the player or headless adapter choose cards to recover from discard.
@abstract func take_cards_from_discard(amount: int) -> AuditOutcome

## Lets the player or headless adapter choose cards to discard from hand.
@abstract func discard_from_hand(amount: int) -> AuditOutcome
