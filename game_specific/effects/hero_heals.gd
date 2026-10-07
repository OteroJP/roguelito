@tool
class_name HeroHeals
extends Effect

@export var amount_to_heal: int

#TODO refactor to new attack system


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	outcome.append(hero.heal(amount_to_heal))


	return outcome


func _effect_text() -> String:
	return "Hero heals %d" % amount_to_heal
