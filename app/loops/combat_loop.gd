class_name CombatLoop extends Loop

var phases: Array[Loop]
var end_conditions: Array[EndCondition]
var _current_phase


func _init(
	hero_character,
	villian_character,
	end_loop_triggers,
	loop_phases,
	) -> void:
		assert(phases.size()>0 and end_conditions.size()>0
		, "There should be at least a [CombatPhase] and an [EndCondition]"
		)
		_current_phase = 0
		phases = loop_phases
		end_conditions = end_loop_triggers






func _should_end(current):
	var was_satisfied: Callable = (
		func(condition: EndCondition): 
			return condition.was_satisfied()
			)
	return end_conditions.any(was_satisfied)
