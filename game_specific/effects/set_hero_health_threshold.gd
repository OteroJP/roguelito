@tool
class_name SetHeroHealthThreshold
extends Effect

@export var new_health: int
@export var threshold: int
@export var bonus_threshold: int

var _owner_is_in_second_phase: bool = false



func prepare(effect_owner_port: CharacterPort) -> void:
    var villain := effect_owner_port.get_character() as Villain
    _owner_is_in_second_phase = villain != null and villain.is_in_second_phase()


func apply(target: Character) -> bool:
    if target.health <= threshold or (
        _owner_is_in_second_phase and target.health <= bonus_threshold
    ):
        if target.health == new_health:
            return false
        target.health = new_health
        return true
    return false


func _effect_text() -> String:
    var bonus_text := (
        "[color=#%s](%s if Villain in second phase)[/color]"
        % [UIAssets.VILLAIN_SECOND_PHASE_COLOR, bonus_threshold]
    )
    return "If Hero's health is equal or less than %s %s, change it to %s" % [
        threshold,
        bonus_text,
        new_health
    ]
