
@tool
class_name VillainAttackHealthCost
extends Effect

@export var damage: int
@export var ignores_armor: bool = false
@export var life_cost: int = 1
@export var life_cost_second_main_phase: int = 0


func _on_clash(
	villain: Villain,
	hero: Hero,
	villain_port: VillainPort,
	_hero_port: HeroPort,
	combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	outcome.append(combat_manager.perform_attack(villain_port, villain, hero, damage, ignores_armor))
	var health_cost := life_cost
	if villain.is_in_second_phase():
		health_cost = life_cost_second_main_phase
	outcome.append(villain.take_damage(health_cost, true))


	return outcome


func _clear_effect_data() -> void:
	pass


func _effect_text() -> String:
	var bonus_text := "[color=#%s](%s if in second phase)[/color]" % [UIAssets.VILLAIN_SECOND_PHASE_COLOR, life_cost_second_main_phase]
	var ignore_armor_text := ""
	if ignores_armor:
		ignore_armor_text = ", ignoring armor"
	var text := "Villain attacks for %s damage %s, then loses %s health %s" % [damage, ignore_armor_text, life_cost, bonus_text]
	return text
