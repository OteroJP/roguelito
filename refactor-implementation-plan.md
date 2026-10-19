# Refactor implementation plan

This plan breaks the refactor into macrosteps. At the end of each macrostep, the game should work as it did before that step. Individual edits inside a macrostep may temporarily break things while the related changes are being made.

The same-type character state-copy and restore methods are already in place. Keep that work as step 1 and build on it.

## 1. Introduce ports and `CombatManager`

- [x] **1. Add both role-specific ports.** Define separate Hero and Villain contracts for the operations phases and effects need.
- [x] **2. Add `CombatManager`.** Make it a combat-scoped object, not an autoload. Give it the initial interface for managing ordered effect batches and combat-owned state.
- [x] **3. Implement both visual adapters and connect the first phases.** Have `CombatRoom` create the adapters and pass them to `PlayerTurn` and `UpkeepLoop`. Move the visual setup, presentation, and waits for those flows out of `Hero` and `Villain` as they move behind the adapters.
- [x] **4. Connect the existing card-resolution path to the ports and manager.** Route card effect execution through the new interfaces using the current `GameManager` path. `CombatRoom` passes the manager to `GameManager` during setup, like `ux_delay`; the manager is not an autoload. This is a temporary bridge: microstep 14 moves card-condition and effect-batch orchestration into `Resolution`, while card ordering remains in `GameManager` until the next macrostep.
- [x] **5. Establish the shared effect flow.** Effects receive the relevant ports and `CombatManager`. They request any player choice through a port and apply domain changes. The current implementation clears temporary decision data; microstep 13 replaces that cleanup with a fresh effect instance for each run. Phases decide when and in what order effect batches run; `CombatManager` executes each ordered batch sequentially. Cards and statuses provide effects but do not carry ports.
- [x] **6. Convert direct data-changing effects.** Move attacks, damage, healing, stat changes, and similar effects to the shared flow.
- [x] **7. Convert interaction effects.** Move effects that need player choices or presentation waits to request them through the adapters via ports.
- [x] **8. Remove the remaining character-to-visual calls.** Do this after the effect callers have moved to ports, so each removed visual responsibility already has an adapter owner.
- [x] **9. Move status ownership and lifecycle to `CombatManager`.** Statuses keep their own duration and effect data; the manager owns the active collection, ticking, and removal. Remove the corresponding character-owned fields and methods as part of this move.
- [x] **10. Move attack modifiers and speed bonuses to `CombatManager`.** Modifiers keep their own values and remaining uses. Keep stance, current symbol, and symbol count on the characters; remove the old character-owned modifier and speed APIs as part of this move.
- [x] **11. Reassign the remaining end-of-phase work and triggers.** `Resolution` owns post-card ordering and cleanup. Replace generic port `end_phase()` calls with specific operations for clearing Hero immunity and discarding Villain cards above the hand limit. Keep stance and symbol updates in the phase; preserve card completion signaling until microstep 14 moves card lifecycle out of card methods.
- [x] **12. Update reset and finish the integration.** Save and restore `CombatManager` state with the typed character copies. Reconnect restored status and modifier lifecycle signals, then resynchronize combat indicators through the adapters.
- [x] **13. Give each effect execution a fresh instance.** In `CombatManager`'s shared effect runner, create a fresh instance from each configured effect before executing it, preserving its configured values and giving temporary interaction fields fresh defaults. Apply this to effects supplied by cards, spells, statuses, and other sources. Remove `_clear_effect_data()` and its concrete overrides; discard each execution instance after its run.
- [x] **14. Make card resources data-only and move card effect selection to `Resolution`.** Keep card properties, effect definitions, and card conditions on `CardData` and its subtypes, but remove runtime `on_play()` and `on_clash()` orchestration and direct runtime dependencies on live characters, ports, or `CombatManager`. `Resolution` receives the selected card, derives its source, evaluates its stance, symbol, and other card conditions, selects the applicable effect definitions, and submits each batch to `CombatManager`. Played-card discard now moves through the character ports and updates both the deck and playing-area visual. `GameManager` continues to determine faster/slower card order until Macrostep 2.

The accepted effect execution division is that phases choose when effects trigger and their order, while `CombatManager` executes each ordered batch. The manager does not handle player input or presentation; the adapters do.

At the end of this macrostep, the game must remain runnable. The `GameManager` reference to `CombatManager` is a temporary bridge for the current resolution path and is removed in the next macrostep.

## 2. Move resolution out of `GameManager`

- Move card ordering and faster/slower dispatch from `GameManager` into `Resolution`; card-condition checks and effect-batch selection already belong to `Resolution` from Macrostep 1.
- Remove the temporary `CombatManager` reference from `GameManager`; keep shared effect execution in `CombatManager`, with phase timing and ordering decisions in the phases.
- Keep `GameManager`'s `ux_delay` for now. Removing `GameManager` or relocating that value belongs to a later refactor.

This follows step 1 because current resolution and cancel-effect paths rely on `GameManager`. Moving them first would require an interim owner that would need to change again.

## 3. Move `CombatInput` waits into the adapters and complete reset

- Move confirmation waits and reset cancellation from `CombatInput` into the visual adapters that own the active player interaction. `CombatRoom` requests reset through the adapter interface, and confirmations or resets must not be lost or leak into a later prompt.
- Remove `CombatInput` and its references from `CombatRoom`, `PlayerTurn`, the adapters, and `VillainVisuals` as those waits move to the adapters.
- Preserve current interaction behavior: card and spell confirmations resume their waiting operation, while Ctrl+R cancels the active wait so the loop can restore state.
- Restore characters and `CombatManager` together to the state from the start of the current combat-loop cycle. Reset discards all decisions and changes made during that cycle.
- Ensure reset releases active input or presentation waits so the loop reaches restoration. An effect sequence already in progress may finish; after reset is requested, visual adapters should not enqueue new waits.
- After restoration, have visual adapters synchronize their nodes with restored character and combat state, including card nodes and other transient combat UI.

This combines removing the shared command queue with completing reset synchronization, avoiding an intermediate reset implementation that still depends on `CombatInput`.

## 4. Move effect resolution to commands

- Keep phase ownership of effect timing and ordering. Effects may request player interaction through the ports, then return typed combat-state commands for their requested changes instead of applying those changes directly or depending on `CombatManager` to apply them.
- Have `CombatManager` apply each effect's commands before running the next effect in the batch. It owns shared combat rules and keeps port/domain state synchronized as commands are applied.
- Keep commands separate from `AuditOutcome`. Use relative targets such as `OWNER` and `OPPONENT`; the exact command types and any read-only combat-state access effects need remain design details for this macrostep.
- Revisit the current copy-and-update boundary: effects currently work on character copies from `get_character()` and commit them through `update_character()`. Decide how command application preserves the adapter's ownership of live character mutation and visual synchronization, and whether this flow can avoid copying full characters.
- Review `CombatManager`'s combatant-state keys, currently `CharacterPort` instances. Decide whether commands and target resolution should continue to use port identity or whether state should be keyed by character identity or another stable key, including how that choice behaves during state restoration.

## 5. Rework reporting ownership

- Keep reporting out of character and other domain-resource interfaces.
- Define how phases, adapters, effects, and other relevant components contribute entries to consistent reports, then let `CombatRoom` expose the compiled reports.
- Review the existing audit types only as needed to support that reporting responsibility.

## Working constraints

- Preserve current gameplay behavior at each completed macrostep; the longer-term architecture should allow visual and headless adapters to use the same phase and effect flow.
- Keep character state copies type-specific: common state is restored through `Character`, with Hero and Villain restoring their subtype-specific state.
- Keep cards and statuses focused on their data and effects. Shared combat orchestration belongs to `CombatManager`; phase ordering belongs to phases.
