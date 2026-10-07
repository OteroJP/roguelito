@tool
class_name SetHeroArmor
extends Effect

@export var new_armor: int


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	outcome.append(hero.set_armor(new_armor))


	return outcome


func _effect_text() -> String:
	return "Set hero armor to %d" % new_armor
