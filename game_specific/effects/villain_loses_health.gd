@tool
class_name VillainLosesHealth
extends Effect

@export var life_cost: int = 1
@export var life_cost_second_main_phase: int = 0

var _health_cost: int = 0


func _init() -> void:
	target_side = TargetSide.OWNER


func prepare(effect_owner_port: CharacterPort) -> void:
	var villain := effect_owner_port.get_character() as Villain
	_health_cost = life_cost_second_main_phase if (villain != null and villain.is_in_second_phase()) else life_cost


func apply(target: Character) -> bool:
	var villain := target as Villain
	assert(villain != null, "VillainLosesHealth requires a Villain target.")
	var health_cost := _health_cost
	var previous_health := villain.health
	villain.take_damage(health_cost, true)
	return villain.health != previous_health


func _effect_text() -> String:
	var bonus_text := "[color=#%s](%s if in second phase)[/color]" % [
		UIAssets.VILLAIN_SECOND_PHASE_COLOR,
		life_cost_second_main_phase,
	]
	return "Villain loses %s health %s" % [life_cost, bonus_text]
