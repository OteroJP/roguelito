@tool
class_name HeroTakesDamage
extends Effect

@export var damage: int
@export var ignores_armor: bool = false



func apply(target: Character) -> bool:
    if damage == 0:
        return false
    target.take_damage(damage, ignores_armor)
    return true


func _effect_text() -> String:
    var text := "Hero takes %d damage" % damage
    if ignores_armor:
        text += ", ignoring armor"
    return text
