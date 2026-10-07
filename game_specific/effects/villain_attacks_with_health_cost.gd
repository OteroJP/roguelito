
@tool
class_name VillainAttackHealthCost
extends Effect

@export var damage: int
@export var ignores_armor: bool = false
@export var life_cost: int = 1
@export var life_cost_second_main_phase: int = 0


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	outcome.append(villain.perform_attack(hero, damage, ignores_armor))
	if villain.is_in_second_phase():
		outcome.append(hero.take_damage(life_cost, true))
	else:
		outcome.append(hero.take_damage(life_cost_second_main_phase, true))


	return outcome


func _effect_text() -> String:
	var bonus_text := "[color=#%s](%s if in second phase)[/color]" % [UIAssets.VILLAIN_SECOND_PHASE_COLOR, life_cost_second_main_phase]
	var ignore_armor_text := ""
	if ignores_armor:
		ignore_armor_text = ", ignoring armor"
	var text := "Villain attacks for %s damage %s, then loses %s health %s" % [damage, ignore_armor_text, life_cost, bonus_text]
	return text
