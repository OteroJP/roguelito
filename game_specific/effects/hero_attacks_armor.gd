@tool
class_name HeroAttacksPerArmor
extends Effect

@export var bonus_damage: int
@export var ignores_armor: bool = false

var armor_damage_text: String


func _on_clash(
	villain: Villain,
	hero: Hero,
	_villain_port: VillainPort,
	hero_port: HeroPort,
	combat_manager: CombatManager
) -> void:
	combat_manager.perform_attack(
		hero_port,
		villain,
		hero.max_armor + bonus_damage,
		ignores_armor
	)
	armor_damage_text = str(hero.max_armor)



func _effect_text() -> String:
	var text := "Hero attacks for its max. armor (%s)" % armor_damage_text
	if bonus_damage > 0:
		text += "plus %s" % str(bonus_damage)
	if ignores_armor:
		text += ", ignoring armor"
	return text
