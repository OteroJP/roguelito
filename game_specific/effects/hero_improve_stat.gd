@tool
class_name HeroImproves
extends Effect

enum Stat {HEALTH, BASIC_ATTACK, ARMOR}

@export var stat_to_improve: Stat
@export var amount_to_improve: int

var stat_text: String


func _on_clash(
	_villain: Villain,
	hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> void:
	match stat_to_improve:
		Stat.HEALTH:
			hero.increase_max_health(amount_to_improve)
			stat_text = "its max health"
		Stat.ARMOR:
			hero.increase_max_armor(amount_to_improve)
			stat_text = "its max armor"
		Stat.BASIC_ATTACK:
			hero.increase_max_basic_damage(amount_to_improve)
			stat_text = "its max basic damage"



func _effect_text() -> String:
	return "Hero improves %s by %s" % [stat_text, str(amount_to_improve)]
