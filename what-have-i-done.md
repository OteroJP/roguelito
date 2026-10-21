# What Have I Done?

This change lays the first part of the new effect lifecycle. It does not migrate the existing concrete effects.

## New effect flow

`CombatManager` now runs each effect in two stages:

1. The source character's port awaits `Effect.preparation()` on a character copy, then commits that copy and synchronizes its visuals.
2. `CombatManager` reads `target_side` (`OWNER` or `OPPONENT`) to choose the target port.
3. An `AttackEffect` builds an `Attack` using a `CombatContext` created after preparation. The context contains copies of both characters. `CombatManager` applies the attack modifiers, then awaits `target_port.take_attack()`.
4. A regular `Effect` is applied by awaiting `target_port.apply_effect()`.

The ports run preparation, application, and attacks on character copies, then commit through `update_character()`. That keeps domain updates and visual synchronization together.

## Unresolved issues

- **Effects still call `CombatManager` directly in the old flow.** For example, `CancelHero` and `CancelVillain` call `CombatManager.cancel_hero_card()` and `cancel_villain_card()`. Revisit where these requests belong when migrating the concrete effects; the new effect lifecycle should avoid leaving effects coupled to `CombatManager` for such operations.

## Files changed

| File | Change |
| --- | --- |
| `game_specific/effects/_effect.gd` | Replaced the old clash lifecycle with awaitable `preparation()` and `apply()` hooks; added `target_side`. |
| `game_specific/effects/_attack_effect.gd` | Added the abstract `AttackEffect` contract and `build_attack(context)`. |
| `game_specific/effects/_attack_effect.gd.uid` | Added the Godot UID sidecar for the new script. |
| `game_specific/attack.gd` | Made `Attack` a target-free payload containing damage and armor behavior. |
| `game_specific/combat_manager.gd` | Added effect staging, target selection, `CombatContext`, and shared attack-modifier application. Status effects now use the status holder as their owner. |
| `game_specific/ports/character_port.gd` | Added common port operations for effect preparation, effect application, and receiving an attack. |
| `game_specific/ports/hero_visual_adapter.gd` | Implemented the new operations and synchronized Hero visuals after each commit. |
| `game_specific/ports/villain_visual_adapter.gd` | Implemented the new operations and synchronized Villain visuals after each commit. |
| `game_specific/loops/combat_loop/resolution.gd` | Updated symbol-bonus resolution to pass its owner port to the new effect-batch API. |
| `game_specific/loops/combat_loop/player_turn.gd` | Removed an obsolete commented call using the old effect-batch signature. |
| `what-have-i-done.md` | Recorded this change, its line counts, and its design decisions. |

`HeroPort` and `VillainPort` inherit the new common operations from `CharacterPort`; I did not add duplicate declarations to those subtype interfaces.

## Source line counts

Counts are nonblank lines in `.gd` files, including comments. The baseline is the working tree immediately before this change, including edits that were already present; it is not a count from clean `HEAD`. Markdown and `.uid` files are excluded.

| GDScript file | Before | After | Change |
| --- | ---: | ---: | ---: |
| `game_specific/effects/_effect.gd` | 100 | 67 | -33 |
| `game_specific/effects/_attack_effect.gd` | 0 | 4 | +4 (new) |
| `game_specific/attack.gd` | 9 | 7 | -2 |
| `game_specific/combat_manager.gd` | 215 | 243 | +28 |
| `game_specific/ports/character_port.gd` | 23 | 29 | +6 |
| `game_specific/ports/hero_visual_adapter.gd` | 44 | 56 | +12 |
| `game_specific/ports/villain_visual_adapter.gd` | 136 | 148 | +12 |
| `game_specific/loops/combat_loop/resolution.gd` | 69 | 68 | -1 |
| `game_specific/loops/combat_loop/player_turn.gd` | 48 | 47 | -1 |
| **All GDScript files** | **3,704 across 90 files** | **3,729 across 91 files** | **+25** |

The files that grew are `combat_manager.gd`, both visual adapters, `character_port.gd`, and the new `AttackEffect` script. `_effect.gd`, `attack.gd`, `resolution.gd`, and `player_turn.gd` became smaller. `combat_manager.gd` is the largest growth at 28 nonblank lines.

## Decisions and limits

- `OWNER` and `OPPONENT` are the target choices. The default is `OPPONENT`; effects meant to apply to their owner must set `target_side` to `OWNER`.
- `CombatContext` is nested inside `CombatManager` as requested. Its Hero and Villain values come from the ports' copy-returning `get_character()` methods and are used to calculate attacks after preparation. Effects should treat those snapshots as read-only; changes to them are not committed.
- `Attack` no longer carries a `Character` target. The selected target port applies it to its own character and synchronizes that character's visuals.
- Attack modifiers remain a `CombatManager` responsibility and are applied between `build_attack()` and `take_attack()`.
- The old concrete effect scripts were left untouched. Their `_on_clash()` methods are no longer called by the new manager flow, so card and status effects will not perform their old behavior until those concrete effects are migrated. Their calls to the removed `CombatManager.perform_attack()` also remain in those scripts as part of that deferred migration.
- `preparation()` can be awaited, but this change does not add a new player-choice request interface for effects. The old `_ask_for_interaction()` path was removed; interaction behavior needs to be designed as the concrete effects are migrated.

No automated tests were run for this change.
