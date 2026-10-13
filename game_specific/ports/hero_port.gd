@abstract class_name HeroPort extends RefCounted


## Returns a working copy. Commit changes through update_character().
@abstract func get_character() -> Hero

## Commits a working copy and synchronizes Hero presentation.
@abstract func update_character(character: Hero) -> void

## Changes the Hero's stance and synchronizes its presentation.
@abstract func change_stance(target_stance: Hero.Stance) -> void

## Performs the Hero's draw operation through the selected adapter.
@abstract func draw() -> AuditOutcome

## Performs the Hero's automatic card play through the selected adapter.
@abstract func play_card() -> AuditOutcome
