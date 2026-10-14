@abstract class_name VillainPort extends CharacterPort


@abstract func get_character() -> Villain

## Commits a working copy to the underlying character.
@abstract func update_character(character: Villain) -> void

## Lets the player choose a Villain card and processes that play through the adapter.
@abstract func play_card() -> AuditOutcome

## Starts a new spell-selection session for this PlayerTurn.
@abstract func begin_spell_selection() -> void

## True after the player confirms that they have chosen all desired spells.
@abstract func spells_chosen() -> bool

## Waits for and returns one chosen spell. Returns null when the session ends.
@abstract func choose_spell() -> VillainSpell

## Ends spell selection early, for example when a combat end condition is met.
@abstract func finish_spell_selection() -> void

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
