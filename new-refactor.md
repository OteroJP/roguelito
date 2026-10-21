# Reporting Direction

## Requirement

Combat reports are part of the game behavior. They should show a consistent account of what happened during each phase, be available to `CombatRoom`, and remain usable in a future headless combat run. The report data therefore cannot exist only inside the visual logger.

## Current Flow

The current code has two report paths:

- Character operations and some effects create `AuditEvent`s inside `AuditOutcome`s. `CombatManager` also creates events for operations it owns. Phases append these outcomes to an `AuditReport`.
- `CombatLoop` emits the phase report through `phase_ended`. `CombatRoom` connects that signal to `GameLogger.display_report()`. `GameLogger` formats entries with colors and source tags, then sends the text to the visual `CombatLog`.

Player interaction messages currently take a separate route: `VillainVisuals` emits an interaction signal, the adapter forwards it, and `CombatRoom` connects it to `GameLogger.display_entry()`. `CombatRoom` also logs its own lifecycle messages, such as a reset request.

## Reporting Responsibilities Discussed

- Phases describe the ordered combat sequence and report completed player choices, such as the card returned by a port.
- `CombatManager` reports the combat operations it executes and their outcomes.
- Character resources should not create audit records. The desired direction is also to keep effects from returning `AuditEvent` or `AuditOutcome` objects.
- Only the final chosen card needs to be reported. Individual select, cancel, or replace actions during the visual selection do not need report entries. Reset-request logging may remain a `CombatRoom` responsibility.
- Reports should be structured data first. `GameLogger` and `CombatLog` are presentation consumers; a headless runner should be able to consume the same phase reports.

## Open Question: Reporting Effect Outcomes

Effects are varied enough that their meaning cannot reliably be inferred from a generic character-state diff. For example, a changed speed value does not by itself explain whether a speed effect ran, and a status appearing does not identify the rule that applied it. Accurate reporting needs access to the intent or result at the point the operation occurs.

Two approaches remain under consideration:

1. **Effects return typed combat commands.** `CombatManager` applies each command and records the resulting facts. This centralizes application and reporting, but the command model must represent the distinct changes effects can request.
2. **Effects contribute facts while they execute.** This handles open-ended effects directly, but gives effects a reporting connection that the refactor is trying to remove.

Making effect resources serializable by itself does not resolve this: serialized configuration describes what an effect is set up to do, not necessarily what happened when it ran.

## Open Question: Report Collection and Delivery

Signals from ports and `CombatManager`, with `phase_ended` marking a phase boundary, were discussed as a way for multiple sources to contribute report facts. If used, those signals should feed structured phase reports rather than only the visual logger. It is not yet decided whether collection belongs in existing phase/loop code or needs a separate nonvisual collector. No new collector class is assumed by this note.

## Effects

Effects currently combine several jobs: they can prepare through player interaction, read and change character data, request combat operations from `CombatManager`, and request presentation. Their shared `on_clash()` method receives both characters and both ports, even when an effect only uses one character.

The direction under discussion is an `EffectInterpreter` that coordinates the effect lifecycle. Preparation would act on the character the effect comes from; execution would act on the character it affects. Effects that change both characters would make that explicit. Character ports may own committing character changes and synchronizing the corresponding visuals.

### Relevant Questions

- Should effects have separate preparation and execution hooks, each receiving only its relevant character, with the interpreter calling them and synchronizing whichever character data changed? How should an effect that changes both characters express that?
- Could a character port expose a method that applies an effect to its character and synchronizes its visuals in the visual adapter? Would that give the adapter a clear sync responsibility, and how should player interaction during preparation fit into that boundary?
- How should attacks fit into the same effect-interpreter flow? An effect can prepare an attack from the source character, while combat modifiers transform it and the target character receives it. Should that remain a distinct attack operation within the interpreter, or use the same application path as other effects?
