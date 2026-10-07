@tool
class_name HeroAttacksPerArmor
extends Effect

@export var bonus_damage: int
@export var ignores_armor: bool = false

var armor_damage_text: String


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	outcome.append(hero.perform_attack(villain, hero.max_armor + bonus_damage, ignores_armor))
	armor_damage_text = str(hero.max_armor)

	return outcome


func _effect_text() -> String:
	var text := "Hero attacks for its max. armor (%s)" % armor_damage_text
	if bonus_damage > 0:
		text += "plus %s" % str(bonus_damage)
	if ignores_armor:
		text += ", ignoring armor"
	return text
