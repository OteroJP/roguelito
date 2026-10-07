class_name CombatLoop extends RefCounted

signal phase_ended(report: AuditReport)
signal phase_started(header: String)
signal end_cycle(round_number: int)

var phases: Array[LoopPhase]
var end_conditions: Array[EndCondition]
var _current_phase: int  = -1
var round_number: int = 1
var reset_requested: bool = false
var _save_turn_state: Callable
var _restore_turn_state: Callable
var _is_running: bool = false


func _init(
	end_loop_triggers: Array[EndCondition],
	loop_phases: Array[LoopPhase],
	save_turn_state_callback: Callable,
	restore_turn_state_callback: Callable,
	) -> void:
		assert(loop_phases.size()>0
		, "There should be at least a [CombatPhase]"
		)
		assert(end_loop_triggers.size()>0
		, "There should be at least a [EndCondition]"
		)

		end_conditions = end_loop_triggers
		phases = loop_phases
		_save_turn_state = save_turn_state_callback
		_restore_turn_state = restore_turn_state_callback
		_current_phase = -1
		for phase in phases:
			phase.add_end_condition(_should_end)


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


func request_reset() -> bool:
	if _is_running:
		reset_requested = true
		return true
	return false


func _should_end() -> bool:
	#TBD run report
	var was_satisfied: Callable = (
		func(condition: EndCondition):
			return condition.was_satisfied()
			)
	return end_conditions.any(was_satisfied)
