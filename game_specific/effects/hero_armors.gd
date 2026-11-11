@tool
class_name HeroArmors
extends Effect

@export var amount_to_armor: int



func apply(target: Character) -> bool:
    var hero := target as Hero
    assert(hero != null, "HeroArmors requires a Hero target.")
    var previous_armor := hero.armor
    hero.set_armor(hero.armor + amount_to_armor)
    return hero.armor != previous_armor


func _effect_text() -> String:
    return "Hero gets %d armor" % amount_to_armor
