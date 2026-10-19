@tool
class_name HeroTakesDamage
extends Effect


@export var damage: int
@export var ignores_armor: bool = false


func _on_clash(
	_villain: Villain,
	hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	outcome.append(hero.take_damage(damage, ignores_armor))


	return outcome


func _effect_text() -> String:
	var text := "Hero takes %d damage" % damage
	if ignores_armor:
		text += ", ignoring armor"
	return text
