@tool
class_name SetHeroHealthThreshold
extends Effect

@export var new_health: int
@export var threshold: int
@export var bonus_threshold: int

#TODO refactor to new attack system


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if (hero.health <= threshold or
		(hero.health <= bonus_threshold and
		villain.is_in_second_phase())
		):
		hero.set_health(new_health)


	return outcome


func _effect_text() -> String:
	var bonus_text := "[color=#%s](%s if Villain in second phase)[/color]" % [UIAssets.VILLAIN_SECOND_PHASE_COLOR, bonus_threshold]
	return "If Hero's health is equal or less than %s %s, change it to %s" % [threshold, bonus_text, new_health]
