@tool
class_name HeroImproves
extends Effect

enum Stat {HEALTH, BASIC_ATTACK, ARMOR}

@export var stat_to_improve: Stat
@export var amount_to_improve: int

var stat_text: String


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	match stat_to_improve:
		Stat.HEALTH:
			outcome.append(hero.increase_max_health(amount_to_improve))
			stat_text = "its max health"
		Stat.ARMOR:
			outcome.append(hero.increase_max_armor(amount_to_improve))
			stat_text = "its max armor"
		Stat.BASIC_ATTACK:
			outcome.append(hero.increase_max_basic_damage(amount_to_improve))
			stat_text = "its max basic damage"

	return outcome


func _effect_text() -> String:
	return "Hero improves %s by %s" % [stat_text, str(amount_to_improve)]
