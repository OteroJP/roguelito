@tool
class_name VillainAttackArmor
extends Effect

@export var multiplier: int = 1
@export var bonus_multiplier: int = 2
@export var ignores_armor: bool = false


func _on_clash(
	villain: Villain,
	hero: Hero,
	villain_port: VillainPort,
	_hero_port: HeroPort,
	combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if villain.is_in_second_phase():
		outcome.append(
			combat_manager.perform_attack(
				villain_port, villain, hero, hero.max_armor * bonus_multiplier, ignores_armor
			)
		)
	else:
		outcome.append(
			combat_manager.perform_attack(
				villain_port, villain, hero, hero.max_armor * multiplier, ignores_armor
			)
		)


	return outcome


func _clear_effect_data() -> void:
	pass


func _effect_text() -> String:
	var amount := "the hero's max armor" if multiplier == 1 else ("%d times the hero's max armor" % multiplier)
	var bonus_amount := "the hero's max armor" if bonus_multiplier == 1 else ("%d times the hero's max armor" % bonus_multiplier)
	var bonus_text := "[color=#%s](%s if in second phase)[/color]" % [UIAssets.VILLAIN_SECOND_PHASE_COLOR, bonus_amount]
	var text := "Villain attacks for %s as damage %s" % [amount, bonus_text]
	if ignores_armor:
		text += ", ignoring armor"
	return text
