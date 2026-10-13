# Refactor implementation plan

This plan breaks the refactor into macrosteps. At the end of each macrostep, the game should work as it did before that step. Individual edits inside a macrostep may temporarily break things while the related changes are being made.

The same-type character state-copy and restore methods are already in place. Keep that work as step 1 and build on it.

## 1. Introduce ports and `CombatManager`

- [ ] **1. Add both role-specific ports.** Define separate Hero and Villain contracts for the operations phases and effects need.
- [ ] **2. Add `CombatManager`.** Make it a combat-scoped object, not an autoload. Give it the initial interface for managing ordered effect batches and combat-owned state.
- [ ] **3. Implement both visual adapters and connect the first phases.** Have `CombatRoom` create the adapters and pass them to `PlayerTurn` and `UpkeepLoop`. Move the visual setup, presentation, and waits for those flows out of `Hero` and `Villain` as they move behind the adapters.
- [ ] **4. Connect `Resolution` to the ports and manager.** Route card effect execution through the new interfaces while keeping card ordering and resolution ownership in `GameManager` for now. `CombatRoom` passes the manager to `GameManager` during setup, like `ux_delay`; the manager is not an autoload. The later resolution macrostep removes this temporary reference.
- [ ] **5. Establish the shared effect flow.** Effects receive the relevant ports and `CombatManager`. They request any player choice through a port, apply domain changes, and clear temporary decision data. Phases decide when and in what order effect batches run; `CombatManager` executes each ordered batch sequentially. Cards and statuses provide effects but do not carry ports.
- [ ] **6. Convert direct data-changing effects.** Move attacks, damage, healing, stat changes, and similar effects to the shared flow.
- [ ] **7. Convert interaction effects.** Move effects that need player choices or presentation waits to request them through the adapters via ports.
- [ ] **8. Remove the remaining character-to-visual calls.** Do this after the effect callers have moved to ports, so each removed visual responsibility already has an adapter owner.
- [ ] **9. Move status ownership and lifecycle to `CombatManager`.** Statuses keep their own duration and effect data; the manager owns the active collection, ticking, and removal. Remove the corresponding character-owned fields and methods as part of this move.
- [ ] **10. Move attack modifiers and speed bonuses to `CombatManager`.** Modifiers keep their own values and remaining uses. Keep stance, current symbol, and symbol count on the characters; remove the old character-owned modifier and speed APIs as part of this move.
- [ ] **11. Reassign the remaining `end_phase()` and trigger work.** Put each behavior in its owner, then remove the obsolete character methods. Keep phase timing and stance or symbol checks outside the effect implementations.
- [ ] **12. Update reset and finish the integration.** Save and restore manager state with the typed character copies, resynchronize visuals through the adapters, and confirm the completed macrostep still runs through combat and reset.

The accepted effect execution division is that phases choose when effects trigger and their order, while `CombatManager` executes each ordered batch. The manager does not handle player input or presentation; the adapters do.

At the end of this macrostep, the game must remain runnable. The `GameManager` reference to `CombatManager` is a temporary bridge for the current resolution path and is removed in the next macrostep.

## 2. Move resolution out of `GameManager`

- Move card ordering and faster/slower card resolution into the `Resolution` phase.
- Remove the temporary `CombatManager` reference from `GameManager`; keep shared effect execution in `CombatManager`, with phase timing and ordering decisions in the phases.
- Keep `GameManager`'s `ux_delay` for now. Removing `GameManager` or relocating that value belongs to a later refactor.

This follows step 1 because current resolution and cancel-effect paths rely on `GameManager`. Moving them first would require an interim owner that would need to change again.

## 3. Complete reset and visual synchronization

- Restore characters and `CombatManager` together to the state from the start of the current combat-loop cycle. Reset discards all decisions and changes made during that cycle.
- Ensure a reset request releases active input or presentation waits so the loop can reach restoration. An effect sequence already in progress may finish; after reset is requested, visual adapters should not enqueue new waits.
- After restoration, have visual adapters synchronize their nodes with restored character and combat state, including card nodes and other transient combat UI.

Reset must remain functional at the end of every earlier macrostep; this step completes synchronization after the ownership changes.

## 4. Rework reporting ownership

- Keep reporting out of character and other domain-resource interfaces.
- Define how phases, adapters, effects, and other relevant components contribute entries to consistent reports, then let `CombatRoom` expose the compiled reports.
- Review the existing audit types only as needed to support that reporting responsibility.

## 5. Remove `CombatInput`

- Move confirmation waits and reset cancellation into the visual adapters that own the active player interaction.
- Have `CombatRoom` request reset through the adapter interface so a reset releases any currently awaited interaction. Ensure a confirmation or reset cannot be lost or leak into a later prompt.
- Remove `CombatInput` and its references from `CombatRoom`, `PlayerTurn`, the adapters, and `VillainVisuals` once their waits use the adapter-owned flow.
- Preserve current behavior: card and spell confirmations resume their waiting operation, and Ctrl+R cancels the active wait so the loop can restore state.

Do this after reset handling is stable through the adapters, so removing the shared command queue does not strand an awaited phase or lose a reset request.

## Working constraints

- Preserve current gameplay behavior at each completed macrostep; the longer-term architecture should allow visual and headless adapters to use the same phase and effect flow.
- Keep character state copies type-specific: common state is restored through `Character`, with Hero and Villain restoring their subtype-specific state.
- Keep cards and statuses focused on their data and effects. Shared combat orchestration belongs to `CombatManager`; phase ordering belongs to phases.
