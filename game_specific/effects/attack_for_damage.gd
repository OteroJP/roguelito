@tool
class_name AttackForDamage
extends Effect

@export var damage: int
@export var ignores_armor: bool = false



func build_attack(_owner: Character, _target: Character) -> Attack:
    return Attack.new(damage, ignores_armor)


func _effect_text() -> String:
    var text := "Attacks for %d damage" % damage
    if ignores_armor:
        text += ", ignoring armor"
    return text
