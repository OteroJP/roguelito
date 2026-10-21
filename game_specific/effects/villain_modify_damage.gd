@tool
class_name VillainModifyDamage
extends Effect

@export var damage_modification: int = 1


func _on_clash(
	_villain: Villain,
	_hero: Hero,
	villain_port: VillainPort,
	_hero_port: HeroPort,
	combat_manager: CombatManager
) -> void:
	var damage_modifier: DamageModifier = DamageModifier.new(1, damage_modification)
	combat_manager.add_attack_modifier(villain_port, damage_modifier)




func _effect_text() -> String:
	if damage_modification < 0:
		return "Villain's attacks deal %d less damage" % absi(damage_modification)
	return "Villain's attacks deal %d more damage" % damage_modification
