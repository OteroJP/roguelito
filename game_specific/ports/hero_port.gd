@abstract class_name HeroPort extends CharacterPort


@abstract func get_character() -> Hero

## Changes the Hero's stance and synchronizes its presentation.
@abstract func change_stance(target_stance: Hero.Stance) -> void

## Moves a randomly chosen Hero card to the playing pile and returns it for the phase to process.
@abstract func play_card() -> HeroCardData
