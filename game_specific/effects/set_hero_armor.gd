@tool
class_name SetHeroArmor
extends Effect

@export var new_armor: int


func _on_clash(
	_villain: Villain,
	hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	outcome.append(hero.set_armor(new_armor))


	return outcome


func _effect_text() -> String:
	return "Set hero armor to %d" % new_armor
