@tool
class_name CharacterImmune
extends Effect



func apply(target: Character) -> bool:
    if target.immune_to_damage:
        return false
    target.immune_to_damage = true
    return true


func _effect_text() -> String:
    return "%s is immune to damage" % target_label().capitalize()
