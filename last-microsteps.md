# Macrostep 1: Microstep Implementation Record

This file records the remaining work in Macrostep 1 as each microstep is implemented. Each completed entry records the changes, critical ownership decisions, likely failure points, and files changed.

## Starting point

- Microsteps 1–10 are marked complete in `refactor-implementation-plan.md`; microsteps 9 and 10 are in commit `0f3f311`.
- The working tree already contains uncommitted symbol-presentation changes for microstep 8. Those earlier edits are not attributed to the later microsteps below; any additional edits to the same files are listed under the microstep that made them.
- Microsteps 11–14 remain to be implemented.

## Microstep 11 — Reassign end-of-phase work and triggers

**Status:** Complete.

**Decisions:** Use operation-specific calls from the phase; do not retain a generic `end_phase()` operation on the character ports. Keep the hand-limit choice behind `VillainPort`. Reset Hero immunity through a specific Hero port operation. Keep card-enabled flags with their current owner until Macrostep 2 moves resolution out of `GameManager`. The phase owns the order and timing of these operations, including stance and symbol changes.

**Changes made:** Moved post-card stance/symbol updates, card completion signals, Hero immunity cleanup, card re-enablement, modifier cleanup, indicator refresh, and the hand-limit discard call into `Resolution`. Added `Hero.clear_immunity()` behind `HeroPort.clear_immunity()`. Renamed `VillainPort.end_phase()` to `discard_over_hand_limit()` so the port exposes the specific player-facing operation. Removed `Hero.end_phase()` and `GameManager.end_phase()`.

**Critical changes:** `Resolution` now owns the order of post-card work and passes character changes through the ports. `GameManager` still owns the two card-enabled flags, but `Resolution` resets them at the former point in the sequence. The `after_clash()` signal call remains temporarily because `Deck` uses it to move resolved cards to discard; microstep 14 replaces card runtime lifecycle methods with explicit port/deck operations.

**Potential errors:** The hand-limit selection and its visual synchronization now run from the renamed villain port operation; their order relative to modifier cleanup and playing-area cleanup must remain as implemented. `after_clash()` is a temporary card-resource method until microstep 14. No runtime test was run in this microstep.

**Files changed:** `game_specific/characters/hero.gd`, `game_specific/combat_room.gd`, `game_specific/game_manager.gd`, `game_specific/loops/combat_loop/resolution.gd`, `game_specific/ports/hero_port.gd`, `game_specific/ports/hero_visual_adapter.gd`, `game_specific/ports/villain_port.gd`, and `game_specific/ports/villain_visual_adapter.gd`.

## Microstep 12 — Save and restore the complete combat state

**Status:** Complete.

**Decisions:** Snapshot `CombatManager` with a same-type `CombatManager` copy. Deep-copy active `Status` resources and copy each `AttackModifier` through its typed `create_state_copy()` method. Recreate runtime signal connections on restore. `CombatRoom` restores this snapshot alongside the Hero and Villain copies, then refreshes indicators through the adapters.

**Changes made:** Added `CombatManager.create_state_copy()` and `restore_state_from()`, including status duration/effects, attack-modifier remaining uses, and speed bonuses for both stable port keys. Added explicit status and modifier signal bind/unbind helpers; restoring reconnects depletion callbacks, and removing a status disconnects its callback. `CombatRoom` now captures the manager snapshot each cycle, restores it with both characters, and resynchronizes status/modifier/speed indicators.

**Critical changes:** The saved manager snapshot is independent of live manager state and can be reused after each reset. Restore checks that the snapshot belongs to the same Hero and Villain port instances. Visuals receive restored manager state only after the live character copies and manager state have been restored.

**Potential errors:** Correct rollback depends on `Status.duplicate(true)` preserving all mutable status fields and `AttackModifier.create_state_copy()` preserving each subtype's mutable fields. The current modifier subtypes only use the base fields. `GameManager`'s own turn snapshot remains a `Dictionary`; converting that is outside this microstep. No runtime test was run in this microstep.

**Files changed:** `game_specific/combat_manager.gd` and `game_specific/combat_room.gd`.

## Microstep 13 — Use fresh effect instances per execution

**Status:** Complete.

**Decisions:** Each configured effect produces a new instance from its concrete script for every execution. Copy only script variables marked for storage; these are the exported configuration fields. Runtime-only fields keep their defaults. Container-valued settings are duplicated, while referenced Resources remain configuration references.

**Changes made:** `CombatManager.run_effect_batch()` now creates an execution copy before calling `on_clash()`. Added `Effect.create_execution_copy()`, removed `_clear_effect_data()` from the base class and removed all 32 concrete overrides. The base `Effect.on_clash()` no longer performs cleanup after execution.

**Critical changes:** Card, spell, status, symbol-bonus, and other effect batches all pass through the shared manager runner, so each run gets isolated temporary fields. The reusable `.tres` effect resources remain configured data; interaction choices and generated text live only on the short-lived execution instance.

**Potential errors:** Copying relies on Godot marking exported script settings with both `PROPERTY_USAGE_SCRIPT_VARIABLE` and `PROPERTY_USAGE_STORAGE`. Resource-valued configuration is intentionally shared and must remain read-only during effect execution; current status-granting effects pass it to `CombatManager.add_status()`, which duplicates the status. No runtime test was run in this microstep.

**Files changed:** `game_specific/effects/_effect.gd`, `game_specific/combat_manager.gd`, and the 32 concrete scripts under `game_specific/effects/` that previously implemented `_clear_effect_data()`.

## Microstep 14 — Make cards data-only and select effects in `Resolution`

**Status:** Complete.

**Decisions:** Keep cards as configuration data and let `Resolution` decide when their configured effects run. `CharacterPort.create_effect_copies()` creates a fresh ordered batch; `CombatManager.run_effect_copies()` executes those copies without copying them a second time. Move Villain symbol-completion processing to the beginning of `Resolution`, before speed sorting, so symbol effects that change speed still affect the card order as they did when they ran during card selection. Keep the existing end-condition check after the faster card. Preserve presentation order by placing the Villain card after symbol effects and before revealing the Hero card. Replace the `CardData.resolved` signal with the explicit `discard_played_card()` port operation, which updates the deck and playing-area visual together. Keep `GameManager`'s card ordering, selected-card state, flags, and temporary `CombatManager` reference for Macrostep 2. Remove the now-unused `GameManager.playing_area` field. The Villain adapter continues to display each card's `symbol_to_complete`; only matching symbols trigger the bonus.

**Changes made:** Removed `CardData.resolved` and its abstract `on_play()`, `on_clash()`, `after_clash()`, and `on_discard()` APIs and removed the implementations from `HeroCardData` and `VillainCardData`. `Resolution` now evaluates Hero stance bonuses, Villain second-phase bonuses, and Villain symbol completion; it selects configured effects, asks the owning port to create effect copies, and submits them to `CombatManager`. It also applies the existing post-clash stance/symbol changes and discards each card through its port. `Deck.discard_played_card()` moves cards from its playing pile to discard without signal wiring. Both visual adapters update the deck and `PlayingArea`; `PlayingArea.discard_card()` removes the matching card node. The old `on_discard()` hooks were no-ops in the only two card subtypes, so `Deck.discard()` no longer calls them. Moved Hero card-selection display timing from `GameManager` into `UpkeepLoop`, and Villain card-selection display timing into `VillainVisualAdapter`. Villain card placement now happens after symbol effects in `Resolution`, before Hero-card reveal and speed sorting. Removed the obsolete `GameManager` play/effect dispatch methods and its unused `PlayingArea` reference.

**Critical changes:** The symbol-completion effect batch runs before `GameManager.sort_cards()`, preserving speed-modifier influence on ordering. Card effect batches are copied once by `CharacterPort` and then executed by `CombatManager`; the separate `run_effect_copies()` path avoids a second copy. Card resolution ordering and lifecycle are now explicit in `Resolution` and the ports instead of being triggered by card-resource methods/signals. The card's data object no longer receives characters, ports, or the combat manager at runtime.

**Potential errors:** Audit entries for symbol bonuses now appear in the `Resolution` report rather than the `PlayerTurn` report; this reporting placement is intentionally deferred to the reporting macrostep. A future card subtype with discard-time behavior must move that behavior to a phase, port, or effect because the removed hooks were the old extension point. `Resolution` still assumes the queue contains exactly one Hero and one Villain card, as the previous code did. The manually maintained `GameManager` card fields remain until Macrostep 2. The phase/adapter ordering and reset behavior were reviewed statically; no runtime test was run.

**Files changed:** `dungeon/playing_area.gd`, `game_specific/cards/_card_data.gd`, `game_specific/cards/hero_card_data.gd`, `game_specific/cards/villain_card_data.gd`, `game_specific/combat_manager.gd`, `game_specific/combat_room.gd`, `game_specific/deck.gd`, `game_specific/game_manager.gd`, `game_specific/loops/combat_loop/player_turn.gd`, `game_specific/loops/combat_loop/resolution.gd`, `game_specific/loops/combat_loop/upkeep.gd`, `game_specific/ports/character_port.gd`, `game_specific/ports/hero_visual_adapter.gd`, and `game_specific/ports/villain_visual_adapter.gd`.
