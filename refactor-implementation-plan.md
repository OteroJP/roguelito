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
- [x] **14. Make card resources data-only.** Keep card properties, effect definitions, and card conditions on `CardData` and its subtypes, but remove runtime `on_play()` and `on_clash()` orchestration and direct runtime dependencies on live characters, ports, or `CombatManager`. `Resolution` owns the order and loop over selected cards; `CombatManager` resolves one supplied card by checking its conditions and running the applicable effect batches. Played-card domain changes go through character ports; the shared playing-area display is managed separately through `CombatPresentationPort`.

The accepted effect execution division is that phases choose the combat sequence and the order in which cards and effect batches run, while `CombatManager` resolves each supplied card and executes each ordered batch. The manager does not handle player input or implement presentation. It delegates shared card-display work through `CombatPresentationPort`; the character adapters continue to handle their own character visuals.

At the end of this macrostep, the game must remain runnable. Macrostep 2 removes the temporary `GameManager` reference to `CombatManager`; `GameManager` remains only for `ux_delay` for now.

## 2. Move card-resolution orchestration into `Resolution`

- Keep the selected Hero and Villain cards and their enabled state on `CombatManager` for the current cycle. Do not snapshot those selections; reset clears them.
- `Resolution` owns the card-resolution sequence and local speed-ordered list. It handles symbol completion, asks `CombatManager` to reveal and sort the cards in one operation and resolve one card at a time, then finalizes the same list through the character ports.
- `CombatManager` delegates shared `PlayingArea` presentation through `CombatPresentationPort`. Character ports update character data and their character-specific visuals.
- Keep `GameManager` limited to `ux_delay`; removing it or relocating that value belongs to a later refactor.

### Microsteps

- [x] **2.1 Route card selections and cancellation through `CombatManager`.** Have the two card-selection phases provide their selected cards to the manager, and have cancel effects update the manager's enabled state.
- [x] **2.2 Move symbol-completion ordering into `Resolution`.** Let the phase read and commit Villain data through `VillainPort` and send matching effect batches to the manager.
- [x] **2.3 Let `Resolution` own the two card passes.** Have the manager reveal the cards and return them speed-ordered in one operation, then resolve one supplied card at a time. Use the same array for finalization; do not retain a second queue in the manager.
- [x] **2.4 Add shared combat presentation through an adapter.** Have `CombatRoom` provide `PlayingAreaVisualAdapter` to the manager, remove `PlayingArea` dependencies from character ports and adapters, and keep frame and presentation-delay waits inside that adapter.
- [x] **2.5 Remove card-resolution use of `GameManager`.** Keep it limited to `ux_delay`; card selection, cancellation, ordering, and presentation no longer read or write its state.

The ordered card list lives only for the duration of `Resolution.run()`. Reset clears the manager's selected cards instead of restoring a copied card-selection object.

## 3. Move `CombatInput` waits into the adapters and complete reset

- Move confirmation waits and reset cancellation from `CombatInput` into the visual adapters that own the active player interaction. `CombatRoom` requests reset through the adapter interface, and confirmations or resets must not be lost or leak into a later prompt.
- Remove `CombatInput` and its references from `CombatRoom`, `PlayerTurn`, the adapters, and `VillainVisuals` as those waits move to the adapters.
- Preserve current interaction behavior: card and spell confirmations resume their waiting operation, while Ctrl+R cancels the active wait so the loop can restore state.
- Restore characters and `CombatManager` together to the state from the start of the current combat-loop cycle. Reset discards all decisions and changes made during that cycle, including the selected cards; selected-card state is cleared rather than snapshotted.
- Ensure reset releases active input or presentation waits so the loop reaches restoration. An effect sequence already in progress may finish; after reset is requested, visual adapters should not enqueue new waits.
- After restoration, have visual adapters synchronize their nodes with restored character and combat state, including card nodes and other transient combat UI.

### Microsteps

- [ ] **3.1 Add adapter-owned queued waits.** Move the queued-command and wake-up behavior needed by Villain player choices into `VillainVisualAdapter`, including checking queued commands before awaiting so early input is retained.
- [ ] **3.2 Move spell selection waits.** Route spell-choice submission and confirmation through the adapter-owned wait path. Remove `PlayerTurn`'s direct dependency on `CombatInput` and preserve immediate spell resolution and reset unwinding.
- [ ] **3.3 Move single-card confirmation waits.** Have `VillainVisuals` submit card-selection actions through the adapter's public interface; let the adapter own the confirmation wait and return the selected card or cancellation result.
- [ ] **3.4 Move multi-card selection waits.** Route hand-discard and discard-recovery confirmations through the same adapter-owned path, preserving cancellation without mutating the deck.
- [ ] **3.5 Route reset through the adapters.** Have `CombatRoom` notify the adapters when Ctrl+R is pressed so the active wait resumes as canceled and the phase can unwind to restoration.
- [ ] **3.6 Make reset release presentation waits.** Ensure reset can release active adapter-owned presentation waits and prevent new waits from being queued after reset is requested. An effect sequence already in progress may finish before restoration.
- [ ] **3.7 Remove `CombatInput` and finish reset synchronization.** Once no caller uses it, remove the class and its wiring. Restore characters and `CombatManager`, clear selected cards, then synchronize hand card nodes, the shared playing area, and other transient visuals through their adapters.

This combines removing the shared command queue with completing reset synchronization, avoiding an intermediate reset implementation that still depends on `CombatInput`.

## 4. Move effect resolution to commands (superseded)

> **Superseded** by the prepare/apply effect lifecycle introduced in `what-have-i-done.md`.
> Effects now declare changes via `prepare`/`apply`/`build_attack` and `CombatStateChange`;
> the command layer is no longer needed.

- Keep phase ownership of effect timing and ordering. Effects may request player interaction through the ports, then return typed combat-state commands for their requested changes instead of applying those changes directly or depending on `CombatManager` to apply them.
- Have `CombatManager` apply each effect's commands before running the next effect in the batch. It owns shared combat rules and keeps port/domain state synchronized as commands are applied.
- Keep commands separate from `AuditOutcome`. Use relative targets such as `OWNER` and `OPPONENT`; the exact command types and any read-only combat-state access effects need remain design details for this macrostep.
- Revisit the current copy-and-update boundary: effects currently work on character copies from `get_character()` and commit them through `update_character()`. Decide how command application preserves the adapter's ownership of live character mutation and visual synchronization, and whether this flow can avoid copying full characters.
- Review `CombatManager`'s combatant-state keys, currently `CharacterPort` instances. Decide whether commands and target resolution should continue to use port identity or whether state should be keyed by character identity or another stable key, including how that choice behaves during state restoration.

## 5. Rework reporting ownership

- Keep reporting out of character and other domain-resource interfaces.
- Define how phases, adapters, effects, and other relevant components contribute entries to consistent reports, then let `CombatRoom` expose the compiled reports.
- Review the existing audit types only as needed to support that reporting responsibility.

## 6. Make combat modifiers expire when used

- Spend each `AttackModifier` use when it modifies an attack, and remove it as soon as it is depleted.
- Spend speed bonuses when they are used to compare card speeds. Preserve bonuses added after sorting for the next ordering opportunity.
- Remove the end-of-resolution blanket modifier clearing only after both use points are explicit.
- Update modifier indicators when modifiers are added, consumed, depleted, or restored. Keep reset snapshots consistent with their remaining uses and speed bonuses.

### Microsteps

- [ ] **6.1 Consume attack modifiers on attacks.** Apply each modifier to the `Attack`, spend its use at that point, and let depletion remove it from the active collection.
- [ ] **6.2 Consume speed bonuses during card ordering.** Clear the bonuses used for the current sort and preserve bonuses added after that sort for the next one.
- [ ] **6.3 Synchronize modifier indicators and reset state.** Update visual indicators at each modifier state change, verify restored use counts and speed bonuses, and remove the old end-of-resolution clearing call.

## Working constraints

- Preserve current gameplay behavior at each completed macrostep; the longer-term architecture should allow visual and headless adapters to use the same phase and effect flow.
- Keep character state copies type-specific: common state is restored through `Character`, with Hero and Villain restoring their subtype-specific state.
- Keep cards and statuses focused on their data and effects. Shared combat orchestration belongs to `CombatManager`; phase ordering belongs to phases.
