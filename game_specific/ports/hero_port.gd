@abstract class_name HeroPort extends CharacterPort


@abstract func get_character() -> Hero

## Commits a working copy and synchronizes Hero presentation.
@abstract func update_character(character: Hero) -> void

## Changes the Hero's stance and synchronizes its presentation.
@abstract func change_stance(target_stance: Hero.Stance) -> void

## Clears temporary immunity after card resolution.
@abstract func clear_immunity() -> void

## Moves a randomly chosen Hero card to the playing pile and returns it for the phase to process.
@abstract func play_card() -> HeroCardData

## Reveals the Hero's currently played card through the selected adapter.
@abstract func reveal_played_card() -> void
