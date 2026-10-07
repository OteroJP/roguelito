@tool
class_name HeroArmors
extends Effect

@export var amount_to_armor: int


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	outcome.append(hero.set_armor(hero.armor + amount_to_armor))

	return outcome


func _effect_text() -> String:
	return "Hero gets %d armor" % amount_to_armor
