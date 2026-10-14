@tool
class_name HeroAttacksBasic
extends Effect

@export var bonus_damage: int
@export var ignores_armor: bool = false
@export var multiplier: int = 1

var basic_damage: String


func _on_clash(
	villain: Villain,
	hero: Hero,
	_villain_port: VillainPort,
	hero_port: HeroPort,
	combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	outcome.append(
		combat_manager.perform_attack(
			hero_port,
			hero,
			villain,
			hero.basic_damage + bonus_damage,
			ignores_armor
		)
	)
	basic_damage = str(hero.basic_damage * multiplier)

	return outcome


func _clear_effect_data() -> void:
	pass


func _effect_text() -> String:
	var text := "Hero attacks for its basic damage"
	if multiplier > 1:
		text += "%s times" % str(multiplier)
	text += "(%s)" % basic_damage
	if bonus_damage > 0:
		text += "plus %s" % str(bonus_damage)
	if ignores_armor:
		text += ", ignoring armor"
	return text
