class_name CombatLoop extends RefCounted

signal phase_ended(report: AuditReport)

var phases: Array[LoopPhase]
var end_conditions: Array[EndCondition]
var _report: AuditReport
var _current_phase: int  = -1


func _init(
	end_loop_triggers: Array[EndCondition],
	loop_phases: Array[LoopPhase],
	audit_report: AuditReport,
	) -> void:
		assert(loop_phases.size()>0
		, "There should be at least a [CombatPhase]"
		)
		assert(end_loop_triggers.size()>0
		, "There should be at least a [EndCondition]"
		)
		 
		end_conditions = end_loop_triggers
		phases = loop_phases
		_report = audit_report
		_current_phase = -1
		for phase in phases:
			phase.set_report(_report)
			phase.add_end_condition(_should_end)


func run() -> void:
	while not _should_end():
		_current_phase = (_current_phase + 1) % phases.size()
		var phase: LoopPhase = phases[_current_phase]
		_report.clear()
		_report.add("Next phase is starting %s" % phase.get_script().get_global_name(), AuditLogEntry.Source.GAME)
		await phase.run()
		phase_ended.emit(phase.get_report())


func _should_end() -> bool:
	#TBD run report
	var was_satisfied: Callable = (
		func(condition: EndCondition): 
			return condition.was_satisfied()
			)
	return end_conditions.any(was_satisfied)
