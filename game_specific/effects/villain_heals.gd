@tool
class_name VillainHeal
extends Effect

@export var amount_to_heal: int

#TODO refactor to new attack system


func _on_clash(
	villain: Villain,
	hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	outcome.append(villain.heal(amount_to_heal))


	return outcome


func _effect_text() -> String:
	return "Villain heals %d" % amount_to_heal
