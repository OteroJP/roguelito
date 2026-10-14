@tool
class_name VillainAttackHeroDamage
extends Effect

@export var ignores_armor: bool = false

var _hero_max_basic_damage: int = 0


func _on_clash(
	villain: Villain,
	hero: Hero,
	villain_port: VillainPort,
	_hero_port: HeroPort,
	combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	_hero_max_basic_damage = hero.max_basic_damage
	outcome.append(
		combat_manager.perform_attack(
			villain_port, villain, hero, hero.max_basic_damage, ignores_armor
		)
	)


	return outcome


func _clear_effect_data() -> void:
	pass


func _effect_text() -> String:
	var text := "Villain attacks for the hero's max damage (%s)" % _hero_max_basic_damage
	if ignores_armor:
		text += ", ignoring armor"
	return text
