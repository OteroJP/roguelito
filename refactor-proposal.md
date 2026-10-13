# Refactor proposal

The main purpose of the refactor is to separate combat rules and phase orchestration from visual presentation and player input. The longer-term goal is to support a headless combat setup for automated play and balance analysis. To achieve that, neither the character resources nor the effect resources should control visual nodes.

The following aspects of the current `Character` implementation need to change:

- It mixes game rules with visual-flow coordination. Changes to either responsibility can require changing the class, conflicting with the [Single Responsibility Principle](https://en.wikipedia.org/wiki/Single-responsibility_principle).
- It depends on concrete visual nodes: it instantiates specific visuals and calls methods on their concrete types. This ties domain code to presentation code, conflicting with the [Dependency Inversion Principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle).
- Its public contract combines gameplay and visual operations in `prepare()`. A client preparing combat must trigger visual setup even when it does not need visuals, conflicting with the [Interface Segregation Principle](https://en.wikipedia.org/wiki/Interface_segregation_principle).



## Direction: Ports and Adapters

The key point in the refactor will be to stop using `Character` resources as intermediaries for visual systems. Instead, the idea is to use role-specific ports between combat phases and character operations. We need a `Port` abstraction for each `Character` subtype and different adapters as concrete implementations. Each port would have at least a visual adapter and a headless adapter. The object that sets up combat would choose which implementation to use for a given run.

The phases and most existing clients of the characters will call the port rather than visual nodes, directly or indirectly. The `Adapter` coordinates the domain character with coroutines that depend on the selected mode: the visual adapter handles presentation changes and player choices, while the headless adapter supplies automated choices and does no visual work. The port should express the character operations needed by phases, such as drawing, casting spells, and selecting a card, without mechanically copying every character method.

### Implementation status: role-specific ports and visual adapters

The first port step is implemented. `HeroPort` and `VillainPort` define separate role contracts, and `HeroVisualAdapter` and `VillainVisualAdapter` connect those contracts to the current visuals. `CombatRoom` creates the adapters and passes them to `Upkeep`, `PlayerTurn`, and `Resolution`. Player-facing card and spell choices, discard recovery, status presentation, and reset input now pass through the villain adapter, which owns its `CombatInput`; hero stance and status presentation pass through the hero adapter. The ports expose typed `get_character()` copies and `update_character(copy)` commits. Character resources no longer instantiate visual scenes or hold references to visual nodes. `CombatRoom` still creates the saved same-type copies; restore and visual resynchronization go through the adapters.

The effect call path now carries both character resources and role ports. Effects continue to apply rules to the typed character references; the port is used for operations that need visual interaction or synchronization. Changing effects to work through adapter copies and commit calls is still a later part of this proposal. The visual adapter currently configures the existing visual nodes, which still read character data directly; making those nodes consume presentation data from the adapter remains open work. Headless adapter implementations are also deferred.


### Alternative to Ports and Adapters

**[Ports and Adapters](https://en.wikipedia.org/wiki/Hexagonal_architecture_(software)) is the current direction.** Another option would be to create **visual-specific phases with a separate headless phase set**. This approach could keep current visual waits simple: the visual phases would change domain data, tell visuals to update synchronously, and await work from a third object that queues visual changes.

Although, in the project both `Phases` and `Effects` can trigger player choices indirectly through character operations. With the alternative approach, `Effects` would have no clear way to request a choice and receive the player's selection. Splitting effects into visual and nonvisual versions would risk duplicating their rules and could conflict with the Single Responsibility Principle.

In summary, a phase-local visual wait queue alone cannot handle every choice an `Effect` may need, because effects can run from several places in the combat flow. The port boundary could give both phase operations and effect-triggered choices a mode-specific implementation. An additional advantage is that headless combat could share the same phase classes.

### Character access and commit methods

To support both `Effect` instances and the reset mechanism, the port will need to provide character access and commit methods. The proposed interface is:

- `get_character()` provides a working copy of the domain character for effect execution. Creating this saved/working copy is distinct from restoring a live character from a copy.
- `update_character(copy)` commits the changes made to that copy and lets the adapter synchronize its presentation.

Use same-type character copies for working state and reset rollback rather than introducing inner `RefCounted` snapshot classes. `restore_character_state_from(source: Character)` copies the common `Character` state from an already-created copy into the live character. It is a restore/apply operation, not the operation that captures or creates the saved copy; whether this method should be private remains to be decided. Subtype-specific public methods, `Villain.restore_villain_state_from(source: Villain)` and `Hero.restore_hero_state_from(source: Hero)`, will call the common `Character` restore method and then copy their subtype-specific state. The adapter coordinates when to capture a copy, restore from it, and synchronize visuals afterward.

The inner `RefCounted` snapshot alternative would store state separately and use snapshot methods to reach into character internals through private methods. That is a valid encapsulation pattern for a tightly coupled inner helper, but this proposal chooses same-type copies because effects already need working copies of `Hero` and `Villain`. The same type-specific copy/restore mechanism can serve effects and reset rollback without adding a second set of state classes. The current implementation uses a generic `Dictionary` interface; that is less type-explicit and could be refactored here.

**Observation:** Copying must be explicit about all mutable runtime fields; generic `Resource.duplicate(true)` alone is not sufficient.

The exact capture and commit contract still needs to be defined, especially for nested state such as decks, statuses, and modifiers, and for synchronizing visuals after restoration. The current implementation passes state through dictionaries; a more strongly typed solution should be considered.


## Effects

Effects are executable game rules, not only data. They can directly modify `Hero` or `Villain` state, and they can call character operations that may need player input. They are among the main clients of `Character`. For example, a draw effect changes the deck and hand; a discard-recovery effect needs the player to choose cards.

Therefore, effects will need to be redesigned for this refactor. The proposed `Effect` separates domain changes from coroutine waits through two methods: an abstract `_on_clash(villain, hero)` and a concrete `_ask_for_interaction()`. Effects use character APIs for game rules and adapters for player choices. The base class owns a common `on_clash()` that consumes the ports and coordinates calls to those methods. Each concrete effect keeps its own typed rule implementation. The base `Effect` sequence would:

1. Call `_ask_for_interaction()` with the relevant adapters. Its default implementation does nothing; choice-based effects override it and store the typed choice in non-exported fields.
2. Get character copies from the adapters and pass those copies, rather than the ports, to the concrete effect’s `_on_clash()`.
3. Commit the changed character copies through the adapter interface `update_character()`.
4. Call `_clear_effect_data()` so temporary choice data never leaks into a later run.

Effects run sequentially in the current coroutine flow, so temporary typed fields are acceptable for this proposal. Clearing them after every run is mandatory and should be stated in the base class as a comment.

### Effect execution order

Many parts of combat can trigger effects. The phase decides when an effect batch should run and, where relevant, its order (such as the order of cards in Resolution). It passes the batch to the combat-scoped `CombatManager`, which runs the effects in that order. Each effect receives the `CombatManager` along with the relevant character ports, so it can apply combat-owned changes such as adding a status or modifier.

**Observation:** The visual adapter must receive state changes synchronously enough to enqueue any presentation waits before the phase continues.

### Combat state and effect execution

The proposed combat-scoped `CombatManager` handles shared combat mechanics without taking over phase scheduling. The `CombatLoop` provides the manager to the phases; phases decide when and in what order triggers occur, then ask the manager to carry out the relevant mechanics.

- `Upkeep` decides when each combatant's statuses tick. `CombatManager` processes that combatant's active statuses in order, resolves the effects each status exposes, advances each status's own duration, and removes depleted statuses.
- `Resolution` decides card order and which card resolves. It passes the applicable card effects to `CombatManager` for sequential resolution.
- `CombatManager` owns the active collections of statuses and attack modifiers and consults/applies those modifiers during attack resolution. A `Status` keeps its own duration and effects; an `AttackModifier` keeps its own modifier values and remaining uses.
- Stance, current symbol, and symbol count remain character state. Card and symbol conditions select the effects to run; those effects may apply `Status` instances, modifiers, or other changes.
- Effect resolution uses the appropriate character ports for operations that may require player input or visual synchronization. Effects also receive the `CombatManager` so they can change combat-owned state.

`CombatManager` does not select phases, decide card order, or choose which trigger has occurred. Its scope is one combat instance; it is not a global coordinator.

## Awaiting and reset behavior

The visual side needs an await manager or equivalent queue for both player input and presentation work such as animations and tweens. Visual updates and their waits must be registered synchronously. The phase or adapter then waits for the queued work at the appropriate point. Headless operations can complete without visual waits.

Reset semantics discussed so far:

- A reset request does not abort an effect sequence that has already started. The running list of effects completes, then the loop restores the state saved before the combat cycle.
- After reset is requested, the visual await queue accepts no new waits. Animation waits can be skipped so the effect sequence can finish without presentation.
- A player-choice request that occurs after reset must not block the cycle from reaching restoration. Its outcome does not need to be preserved: reset discards the cycle's decisions and changes by restoring the saved state in one operation.
- Restore the characters and `CombatManager` together, at the same reset point, to the state saved at the start of the combat loop cycle.




## Resolution and `GameManager`

Move card ordering and faster/slower card resolution into the `Resolution` phase, and move shared combat-effect, status, and modifier handling to the combat-scoped object described above. This separation is expected to remove `GameManager`'s current gameplay responsibilities. After those moves, `GameManager` will shrink to the globally available `ux_delay` value supplied by `CombatRoom`. Whether to remove `GameManager` and where to place that remaining value are deferred to a separate refactor.

## Likely files reached by the refactor

This is an anticipated impact list, not a claim that every file must change.

### Combat setup, loop, and phases

- `game_specific/combat_room.gd`
- `game_specific/loops/_loop_phase.gd`
- `game_specific/loops/combat_loop/combat_loop.gd`
- `game_specific/loops/combat_loop/combat.gd`
- `game_specific/loops/combat_loop/player_turn.gd`
- `game_specific/loops/combat_loop/upkeep.gd`
- `game_specific/loops/combat_loop/resolution.gd`
- `game_specific/combat_input.gd` (likely replaced, absorbed, or removed)
- `game_specific/ports/hero_port.gd`
- `game_specific/ports/villain_port.gd`
- `game_specific/ports/hero_visual_adapter.gd`
- `game_specific/ports/villain_visual_adapter.gd`
- Any future await-manager scripts

### Characters, cards, and effects

- `game_specific/characters/_character.gd`
- `game_specific/characters/hero.gd`
- `game_specific/characters/villain.gd`
- `game_specific/deck.gd`
- `game_specific/cards/_card_data.gd`
- `game_specific/cards/hero_card_data.gd`
- `game_specific/cards/villain_card_data.gd`
- `game_specific/effects/_effect.gd` and concrete effect scripts under `game_specific/effects/`
- `game_specific/statuses/status.gd`
- `game_specific/spell.gd`
- `game_specific/symbol_bonus.gd`

### Visuals and resolution state

- `dungeon/character/villain_visuals.gd`
- `dungeon/character/hero_visuals.gd`
- `dungeon/character/spell_button.gd`
- `scenes/villain_visuals.tscn` and any character UI scenes changed to support the adapters
- `game_specific/game_manager.gd`

Audit/log files may also be affected if moving resolution changes how outcomes are assembled, but that is not yet established.

## Open design details

- Define exactly what a character copy contains and how `update_character()` commits nested state.
- Define how the `CombatLoop` provides `CombatManager` to phases and how phases provide it to effect execution.
- Decide whether visual changes are applied during `update_character()` or through synchronous model notifications handled by the adapter.
- Extend the Villain design to Hero interactions after the first port is understood.

## Further topics to discuss

- **Combat state and lifecycle:** Move active statuses, attack modifiers, and speed bonuses out of character-owned state and into a combat-scoped object. Keep each `Status` responsible for its own duration and effects, and each `AttackModifier` responsible for its own values and remaining uses. Phases retain trigger timing and ordering; the combat object processes supplied effects and shared combat mechanics. Stance, current symbol, and symbol count remain on their characters. This separation removes character-level `end_phase()` and `tick_statuses()` orchestration and gives shared cleanup and ticking one combat-owned home.
- **`Character` copy and restore:** Replace the generic `Dictionary` turn state with same-type `Hero` and `Villain` copies. Define how the adapter captures those copies. Restore by calling `restore_character_state_from(source: Character)` on the live character; `Hero.restore_hero_state_from(source: Hero)` and `Villain.restore_villain_state_from(source: Villain)` extend the common restore with subtype-specific fields. Keep capture distinct from restore, and have the visual adapter synchronize visuals after restoration. This is the chosen approach over inner `RefCounted` snapshot classes whose methods would apply state through private character interfaces.
- **Reporting ownership:** Reporting is a functional requirement. Decide which components create report entries and how those entries are assembled into consistent phase reports. Keep reporting responsibilities out of character/resource interfaces; review the audit types only to determine whether their current roles and interfaces support that requirement.

## Reporting direction to consider

Keep reporting logic out of character resources. Adapters are the likely producers of audit entries because they coordinate character state commits and player choices. They should receive enough operation or effect context to describe what happened; a state difference alone may not explain why it happened.

A small combat-scoped report recorder can gather and order entries from adapters, phases, effects, and other contributors into phase reports. `CombatRoom` can then expose or display the compiled reports. In this division, adapters create meaningful audit facts, while the recorder provides a shared destination and ordering. The existing `AuditOutcome`, `AuditLogEntry`, and `AuditReport` types remain open for review.

## Current GDScript line-count baseline

Baseline recorded on **2026-10-10** for future refactor audits:

- GDScript files: **85**
- Physical lines across scripts: **4,612**
- Nonblank, non-comment lines: **3,374**

Counts include every `.gd` file found by `rg --files -g '*.gd'`. Physical lines include blank lines and comments. The nonblank, non-comment count excludes blank lines and lines whose first non-whitespace character is `#`; inline comments are counted with their code line. `.gd.uid` files are excluded. This is a simple line-count baseline, not a semantic measure of code complexity.

### Step 2 checkpoint

On **2026-10-12**, the project has **89 GDScript files** and **3,511 nonblank, non-comment lines**. `dungeon/character/villain_visuals.gd` remains the size outlier at **451 nonblank, non-comment lines**.

| Script | Physical lines | Nonblank, non-comment lines |
| --- | ---: | ---: |
| **TOTAL (85 scripts)** | **4,612** | **3,374** |
| `agnostic/audit/audit_event.gd` | 54 | 50 |
| `agnostic/audit/audit_log_entry.gd` | 12 | 8 |
| `agnostic/audit/audit_outcome.gd` | 19 | 14 |
| `agnostic/audit/audit_report.gd` | 74 | 65 |
| `agnostic/audit/combat_log.gd` | 110 | 83 |
| `agnostic/audit/logger.gd` | 72 | 52 |
| `agnostic/content/resource_index.gd` | 164 | 124 |
| `agnostic/share/custom_timer.gd` | 67 | 44 |
| `agnostic/share/label_animation.gd` | 36 | 32 |
| `agnostic/share/range_animation.gd` | 56 | 44 |
| `dungeon/bonus_speed_visual.gd` | 18 | 14 |
| `dungeon/cards/hero_card.gd` | 94 | 59 |
| `dungeon/cards/villain_card.gd` | 89 | 57 |
| `dungeon/character/hero_visuals.gd` | 118 | 92 |
| `dungeon/character/spell_button.gd` | 59 | 41 |
| `dungeon/character/symbol_counter.gd` | 26 | 20 |
| `dungeon/character/villain_visuals.gd` | 567 | 448 |
| `dungeon/damage_modification_visual.gd` | 20 | 16 |
| `dungeon/dialog/dialog_display.gd` | 90 | 65 |
| `dungeon/ignore_armor_visual.gd` | 20 | 16 |
| `dungeon/playing_area.gd` | 62 | 47 |
| `dungeon/stat_icon.gd` | 103 | 81 |
| `dungeon/status_visual.gd` | 71 | 59 |
| `game_specific/attack.gd` | 12 | 9 |
| `game_specific/cards/_card_data.gd` | 158 | 115 |
| `game_specific/cards/hero_card_data.gd` | 36 | 25 |
| `game_specific/cards/villain_card_data.gd` | 39 | 28 |
| `game_specific/characters/_character.gd` | 85 | 59 |
| `game_specific/characters/hero.gd` | 207 | 156 |
| `game_specific/characters/villain.gd` | 252 | 193 |
| `game_specific/combat_input.gd` | 30 | 19 |
| `game_specific/combat_room.gd` | 115 | 91 |
| `game_specific/deck.gd` | 170 | 118 |
| `game_specific/effects/_effect.gd` | 87 | 53 |
| `game_specific/effects/cancel_hero_card.gd` | 16 | 10 |
| `game_specific/effects/cancel_villain_card.gd` | 16 | 10 |
| `game_specific/effects/hero_armors.gd` | 16 | 10 |
| `game_specific/effects/hero_attacks.gd` | 21 | 14 |
| `game_specific/effects/hero_attacks_armor.gd` | 25 | 18 |
| `game_specific/effects/hero_attacks_basic.gd` | 29 | 22 |
| `game_specific/effects/hero_heals.gd` | 19 | 10 |
| `game_specific/effects/hero_immune.gd` | 15 | 9 |
| `game_specific/effects/hero_improve_stat.gd` | 30 | 22 |
| `game_specific/effects/hero_remove_status.gd` | 18 | 12 |
| `game_specific/effects/hero_speeds.gd` | 20 | 12 |
| `game_specific/effects/hero_take_damage.gd` | 22 | 14 |
| `game_specific/effects/hero_take_status.gd` | 18 | 11 |
| `game_specific/effects/reveal_hero_card.gd` | 15 | 9 |
| `game_specific/effects/set_hero_armor.gd` | 17 | 10 |
| `game_specific/effects/set_hero_health_threshold.gd` | 26 | 17 |
| `game_specific/effects/villain_attacks.gd` | 21 | 14 |
| `game_specific/effects/villain_attacks_based_on_armor.gd` | 28 | 21 |
| `game_specific/effects/villain_attacks_based_on_hero_dmg.gd` | 23 | 15 |
| `game_specific/effects/villain_attacks_based_on_symbol.gd` | 28 | 21 |
| `game_specific/effects/villain_attacks_with_health_cost.gd` | 30 | 22 |
| `game_specific/effects/villain_draws.gd` | 18 | 11 |
| `game_specific/effects/villain_heals.gd` | 19 | 10 |
| `game_specific/effects/villain_heals_based_on_symbol.gd` | 25 | 18 |
| `game_specific/effects/villain_immune.gd` | 15 | 9 |
| `game_specific/effects/villain_make_pierce.gd` | 16 | 10 |
| `game_specific/effects/villain_modify_damage.gd` | 20 | 13 |
| `game_specific/effects/villain_modify_damage_with_guaranteed_attack.gd` | 15 | 0 |
| `game_specific/effects/villain_speed_next_cards.gd` | 17 | 11 |
| `game_specific/effects/villain_speeds.gd` | 20 | 12 |
| `game_specific/effects/villain_take_status.gd` | 18 | 11 |
| `game_specific/effects/villain_take_status_if_symbol.gd` | 19 | 13 |
| `game_specific/effects/villain_takes_from_discard.gd` | 17 | 10 |
| `game_specific/end_conditions/_end_condition.gd` | 17 | 7 |
| `game_specific/end_conditions/character_defeated.gd` | 22 | 15 |
| `game_specific/game_manager.gd` | 132 | 104 |
| `game_specific/loops/_loop_phase.gd` | 21 | 10 |
| `game_specific/loops/combat_loop/combat.gd` | 48 | 37 |
| `game_specific/loops/combat_loop/combat_loop.gd` | 79 | 67 |
| `game_specific/loops/combat_loop/player_turn.gd` | 43 | 32 |
| `game_specific/loops/combat_loop/preparation_phases/character_entrance.gd` | 27 | 15 |
| `game_specific/loops/combat_loop/resolution.gd` | 42 | 23 |
| `game_specific/loops/combat_loop/upkeep.gd` | 42 | 31 |
| `game_specific/loops/game_run.gd` | 3 | 2 |
| `game_specific/modifiers/_attack_modifier.gd` | 42 | 31 |
| `game_specific/modifiers/damage_modifier.gd` | 5 | 4 |
| `game_specific/modifiers/pierce_modifier.gd` | 9 | 6 |
| `game_specific/spell.gd` | 9 | 8 |
| `game_specific/statuses/status.gd` | 155 | 117 |
| `game_specific/symbol_bonus.gd` | 7 | 6 |
| `ui_assets.gd` | 45 | 31 |

## Other topics

- Consider returning a typed `CombatStateChangesCommands` collection from `Effect.on_clash()` so effects can request combat-state changes without depending directly on `CombatManager`. `CombatManager` would apply each effect's commands before running the next effect in the batch. Keep these commands separate from `AuditOutcome`, which serves reporting. Decide how commands identify their target and whether effects need to read combat-manager state while resolving.
