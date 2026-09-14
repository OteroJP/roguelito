class_name CombatLoop extends RefCounted

var phases: Array[LoopPhase]
var end_conditions: Array[EndCondition]
var _current_phase: int  = -1


func _init(
	end_loop_triggers,
	loop_phases,
	) -> void:
		assert(phases.size()>0 and end_conditions.size()>0
		, "There should be at least a [CombatPhase] and an [EndCondition]"
		)
		end_conditions = end_loop_triggers
		phases = loop_phases
		_current_phase = -1
		for phase in phases:
			phase.add_end_condition(_should_end)


func run() -> void:
	while not _should_end():
		_current_phase = _current_phase + 1 % phases.size()
		var phase = phases[_current_phase]
		await phase.run()
	

func _should_end() -> bool:
	#TODO run report
	var was_satisfied: Callable = (
		func(condition: EndCondition): 
			return condition.was_satisfied()
			)
	return end_conditions.any(was_satisfied)
