@tool
class_name HeroImmune
extends Effect


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	hero.immune_to_damage = true


	return outcome


func _effect_text() -> String:
	return "Hero is immune to damage"
