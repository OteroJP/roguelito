@tool
class_name HeroAttacks
extends Effect

@export var damage: int
@export var ignores_armor: bool = false


func _on_clash(
	villain: Villain,
	hero: Hero,
	_villain_port: VillainPort,
	hero_port: HeroPort,
	combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	outcome.append(combat_manager.perform_attack(hero_port, hero, villain, damage, ignores_armor))

	return outcome


func _effect_text() -> String:
	var text := "Hero attacks for %d damage" % damage
	if ignores_armor:
		text += ", ignoring armor"
	return text
