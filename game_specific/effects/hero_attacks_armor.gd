@tool
class_name HeroAttacksPerArmor
extends Effect

@export var bonus_damage: int
@export var ignores_armor: bool = false



func build_attack(owner: Character, _target: Character) -> Attack:
    var hero := owner as Hero
    assert(hero != null, "HeroAttacksPerArmor requires a Hero owner.")
    return Attack.new(hero.max_armor + bonus_damage, ignores_armor)


func _effect_text() -> String:
    var text := "Hero attacks for its max armor"
    if bonus_damage > 0:
        text += " plus %d" % bonus_damage
    if ignores_armor:
        text += ", ignoring armor"
    return text
