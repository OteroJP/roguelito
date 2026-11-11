@tool
class_name SetHeroArmor
extends Effect

@export var new_armor: int



func apply(target: Character) -> bool:
    var hero := target as Hero
    assert(hero != null, "SetHeroArmor requires a Hero target.")
    var previous_armor := hero.armor
    hero.set_armor(new_armor)
    return hero.armor != previous_armor


func _effect_text() -> String:
    return "Set hero armor to %d" % new_armor
