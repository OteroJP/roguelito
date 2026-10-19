@tool
class_name HeroArmors
extends Effect

@export var amount_to_armor: int


func _on_clash(
	_villain: Villain,
	hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	outcome.append(hero.set_armor(hero.armor + amount_to_armor))

	return outcome


func _effect_text() -> String:
	return "Hero gets %d armor" % amount_to_armor
