@tool
class_name HeroAttacksBasic
extends Effect

@export var bonus_damage: int
@export var ignores_armor: bool = false
@export var multiplier: int = 1



func build_attack(owner: Character, _target: Character) -> Attack:
    var hero := owner as Hero
    assert(hero != null, "HeroAttacksBasic requires a Hero owner.")
    var damage := hero.basic_damage * multiplier + bonus_damage
    return Attack.new(damage, ignores_armor)


func _effect_text() -> String:
    var text := "Hero attacks for its basic damage"
    if multiplier > 1:
        text += " %d times" % multiplier
    if bonus_damage > 0:
        text += " plus %d" % bonus_damage
    if ignores_armor:
        text += ", ignoring armor"
    return text
