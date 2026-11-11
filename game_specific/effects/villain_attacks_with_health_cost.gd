@tool
class_name VillainAttackHealthCost
extends Effect

@export var damage: int
@export var ignores_armor: bool = false
@export var life_cost: int = 1
@export var life_cost_second_main_phase: int = 0



func build_attack(_owner: Character, _target: Character) -> Attack:
    return Attack.new(damage, ignores_armor)


func _effect_text() -> String:
    var bonus_text := "[color=#%s](%s if in second phase)[/color]" % [
        UIAssets.VILLAIN_SECOND_PHASE_COLOR,
        life_cost_second_main_phase
    ]
    var ignore_armor_text := ", ignoring armor" if ignores_armor else ""
    return "Villain attacks for %s damage %s, then loses %s health %s" % [
        damage,
        ignore_armor_text,
        life_cost,
        bonus_text
    ]
