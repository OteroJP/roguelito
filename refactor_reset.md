# Combat Turn Reset Refactor

## Summary

Ctrl+R now interrupts the active player-input wait, lets the current phase unwind, restores the state saved before Upkeep, removes that turn attempt's combat log entries, and restarts at Upkeep. `CombatRoom` owns the reset flow and the per-combat input queue; `CombatLoop` has no reset signal.

## Decisions taken

`CombatInput` is a small per-combat object created and owned by `CombatRoom`. It holds a queue of commands and a signal that wakes a waiter. Wait methods check the queue before awaiting, so a reset submitted just before a wait begins is not lost. Confirmation buttons submit commands through this object; Ctrl+R queues a reset and marks the loop to restore after the phase returns.

Two command-handling designs were considered:

1. **Existing UI waits consume commands — chosen.** `VillainVisuals` keeps its selection and presentation logic, replacing direct confirmation awaits with `CombatInput.wait_for_command()`. This is the smaller change and keeps selection behavior with the UI that owns it. A reset returns a cancellation result up the existing call chain so the phase can unwind.
2. **The phase consumes every command.** `PlayerTurn` would read all card, spell, discard, and recovery commands and direct the UI. This centralizes decision handling and may make phase logic easier to test or replay, but requires moving selection behavior out of `VillainVisuals` and handling nested effect-driven selections in the phase.

Option 1 was chosen because it provides a queued, reliable wake-up path without relocating the existing selection flows or adding reset interfaces to Hero/Villain resources.

## State saved and restored

`CombatRoom` coordinates snapshots from Hero, Villain, and `GameManager`. The state is captured before the first Upkeep and again before each following Upkeep.

- `Character` saves common character fields, deck state, active statuses, and runtime attack modifiers.
- `Deck` saves draw pile, hand, playing area, and discard pile. Restoring also reconnects card resolution signals.
- `Hero` saves basic damage and armor values, immunity, and stance in addition to common character state.
- `Villain` saves mana, phase thresholds, immunity, current symbol, and symbol counts in addition to common character state.
- `AttackModifier` saves its script and runtime values so modifiers can be recreated with their remaining uses.
- `GameManager` saves both current cards, their enabled flags, and the resolution order.

Restoration refreshes the character visuals, rebuilds the Villain hand card nodes from the restored deck hand, clears both played-card nodes from the playing area, and updates the cancellation overlays. `CombatLog` marks the start of each turn after its round header and erases later entries when that attempt is reset.

## Input waits and phase behavior

`CombatRoom` owns `CombatInput` and passes it to `VillainVisuals`, which is the node with player confirmation waits. The single-card confirmation, hand-discard confirmation, discard-recovery confirmation, and spell confirmation waits now await queued commands. A reset command wakes the active wait; canceled card/recovery selections return without changing the deck. Spell resolutions already in progress finish before the phase unwinds and state is restored. The room then rebuilds hand UI nodes from the restored deck and removes stale playing-area card nodes.

`PlayerTurn` receives the same `CombatInput` reference and checks its reset flag after each awaited action, so it does not proceed from canceled spell selection to card selection. `UpkeepLoop` and `Resolution` need no direct input-queue changes: any nested VillainVisuals wait they call returns on reset, then the active phase finishes and the loop restores state.

## `CombatLoop.run()` comparison

### Before modification

```gdscript
func run() -> void:
	while not _should_end():
		_current_phase += 1
		if _current_phase >= phases.size():
			_current_phase = 0
			round_number += 1
			end_cycle.emit(round_number)
		var phase: LoopPhase = phases[_current_phase]
		phase_started.emit(phase.get_audit_header())
		await phase.run()
		var report: AuditReport = phase.get_report()
		for condition: EndCondition in end_conditions:
			if condition.was_satisfied():
				report.append(condition.get_outcome())
		phase_ended.emit(report)
```

### Example provided

```gdscript
func run() -> void:
	save_turn_state.call() # before Upkeep runs
	while not _should_end():
		if _current_phase == phases.size() - 1:
			save_turn_state.call() # after all phases, before Upkeep
		_current_phase = (_current_phase + 1) % phases.size()
		var phase = phases[_current_phase]
		await phase.run()
		if reset_requested:
			restore_turn_state.call()
			_current_phase = -1
			reset_requested = false
	GameManager.add_debug("Combat loop ended", GameManager.LogSource.GAME)
```

### After modification

```gdscript
func run() -> void:
	_is_running = true
	if _save_turn_state.is_valid():
		_save_turn_state.call()
	while not _should_end():
		if _current_phase == phases.size() - 1:
			if _save_turn_state.is_valid():
				_save_turn_state.call()
			round_number += 1
			end_cycle.emit(round_number)
		_current_phase = (_current_phase + 1) % phases.size()
		var phase: LoopPhase = phases[_current_phase]
		phase_started.emit(phase.get_audit_header())
		await phase.run()
		var report: AuditReport = phase.get_report()
		for condition: EndCondition in end_conditions:
			if condition.was_satisfied():
				report.append(condition.get_outcome())
		phase_ended.emit(report)
		if reset_requested:
			if _restore_turn_state.is_valid():
				await _restore_turn_state.call()
			_current_phase = -1
			reset_requested = false
	_is_running = false
```

The save/restore callbacks are supplied to `CombatLoop._init()` by `CombatRoom`. Ctrl+R is handled by the room, which queues reset in `CombatInput` and sets the loop's reset flag; the loop itself does not emit a reset signal.

## Files modified

- `game_specific/combat_input.gd`, `game_specific/combat_room.gd`, and `game_specific/loops/combat_loop/combat_loop.gd`
- `game_specific/loops/combat_loop/player_turn.gd`, `dungeon/character/villain_visuals.gd`, and `game_specific/characters/villain.gd`
- Snapshot and log support remains in `game_specific/characters/_character.gd`, `game_specific/characters/hero.gd`, `game_specific/deck.gd`, `game_specific/modifiers/_attack_modifier.gd`, `game_specific/game_manager.gd`, `agnostic/audit/combat_log.gd`, `agnostic/audit/logger.gd`, and `dungeon/character/hero_visuals.gd`
