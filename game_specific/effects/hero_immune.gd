@tool
class_name HeroImmune
extends Effect


func _on_clash(
	_villain: Villain,
	hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	hero.immune_to_damage = true


	return outcome


func _effect_text() -> String:
	return "Hero is immune to damage"
