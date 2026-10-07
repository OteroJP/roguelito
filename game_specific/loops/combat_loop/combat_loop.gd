class_name CombatLoop extends RefCounted

signal phase_ended(report: AuditReport)
signal phase_started(header: String)
signal end_cycle(round_number: int)

var phases: Array[LoopPhase]
var end_conditions: Array[EndCondition]
var _current_phase: int  = -1
var round_number: int = 1


func _init(
	end_loop_triggers: Array[EndCondition],
	loop_phases: Array[LoopPhase],
	) -> void:
		assert(loop_phases.size()>0
		, "There should be at least a [CombatPhase]"
		)
		assert(end_loop_triggers.size()>0
		, "There should be at least a [EndCondition]"
		)

		end_conditions = end_loop_triggers
		phases = loop_phases
		_current_phase = -1
		for phase in phases:
			phase.add_end_condition(_should_end)


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


func _should_end() -> bool:
	#TBD run report
	var was_satisfied: Callable = (
		func(condition: EndCondition):
			return condition.was_satisfied()
			)
	return end_conditions.any(was_satisfied)
