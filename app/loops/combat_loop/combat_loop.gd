class_name CombatLoop extends RefCounted

var phases: Array[LoopPhase]
var end_conditions: Array[EndCondition]
var _current_phase: int  = -1


func _init(
	end_loop_triggers,
	loop_phases,
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
		_current_phase = (_current_phase + 1) % phases.size()
		var phase = phases[_current_phase]
		print("next phase is starting ", phase.get_script().get_global_name())
		await phase.run()
	print("Combat loop ended")


func _should_end() -> bool:
	#TBD run report
	var was_satisfied: Callable = (
		func(condition: EndCondition): 
			return condition.was_satisfied()
			)
	return end_conditions.any(was_satisfied)
