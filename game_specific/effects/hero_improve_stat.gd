@tool
class_name HeroImproves
extends Effect

enum Stat { HEALTH, BASIC_ATTACK, ARMOR }

@export var stat_to_improve: Stat
@export var amount_to_improve: int



func apply(target: Character) -> bool:
	var hero := target as Hero
	assert(hero != null, "HeroImproves requires a Hero target.")
	if amount_to_improve == 0:
		return false
	match stat_to_improve:
		Stat.HEALTH:
			hero.increase_max_health(amount_to_improve)
		Stat.ARMOR:
			hero.increase_max_armor(amount_to_improve)
		Stat.BASIC_ATTACK:
			hero.increase_max_basic_damage(amount_to_improve)
	return true


func _effect_text() -> String:
	var stat_name: String
	match stat_to_improve:
		Stat.HEALTH:
			stat_name = "its max health"
		Stat.ARMOR:
			stat_name = "its max armor"
		Stat.BASIC_ATTACK:
			stat_name = "its max basic damage"
	return "Hero improves %s by %s" % [stat_name, str(amount_to_improve)]
