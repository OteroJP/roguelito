@tool
class_name CharacterHeals
extends Effect

@export var amount_to_heal: int



func apply(target: Character) -> bool:
    var previous_health := target.health
    target.heal(amount_to_heal)
    return target.health != previous_health


func _effect_text() -> String:
    return "%s heals %d" % [target_label().capitalize(), amount_to_heal]
