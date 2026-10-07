class_name Combat extends RefCounted

var _end_conditions: Array[EndCondition]
var _preparation_steps: Array[LoopPhase]
var _phases: Array[LoopPhase]
var _current_phase: int  = -1


func _init(
	preparation_steps, # TBD: add preparation ending condition?
	loop_phases,
	end_triggers,
	) -> void:
		assert(
			end_triggers.size()>0 and loop_phases.size()>0
			, "There should be at least a [LoopPhase] and an [EndCondition]"
		)
		_phases = loop_phases
		_end_conditions = end_triggers
		_preparation_steps = preparation_steps
		for phase in _phases:
			phase.add_end_condition(_should_end)


func prepare() -> void:
	var _step_ix: int  = 0
	while _step_ix < _preparation_steps.size():
		await _preparation_steps[_step_ix].run()
		_step_ix += 1


func run() -> void:
	#TODO Apply on-combat-start effects
	while not _should_end():
		_current_phase = (_current_phase + 1) % _phases.size()
		var phase = _phases[_current_phase]
		print("next phase is starting [ %s ]" % phase.get_script().get_global_name())
		await phase.run()
	print("Combat loop ended")


func _should_end() -> bool:
	#TBD run report
	var was_satisfied: Callable = (
		func(condition: EndCondition): 
			return condition.was_satisfied()
			)
	return _end_conditions.any(was_satisfied)
