@tool
class_name VillainAttackHeroDamage
extends Effect

@export var ignores_armor: bool = false



func build_attack(_owner: Character, target: Character) -> Attack:
    var hero := target as Hero
    assert(hero != null, "VillainAttackHeroDamage requires a Hero target.")
    return Attack.new(hero.max_basic_damage, ignores_armor)


func _effect_text() -> String:
    var text := "Villain attacks for the hero's max basic damage"
    if ignores_armor:
        text += ", ignoring armor"
    return text
