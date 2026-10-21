@tool
class_name VillainAttack
extends Effect

@export var damage: int
@export var ignores_armor: bool = false


func _on_clash(
	villain: Villain,
	hero: Hero,
	villain_port: VillainPort,
	_hero_port: HeroPort,
	combat_manager: CombatManager
) -> void:
	combat_manager.perform_attack(villain_port, hero, damage, ignores_armor)




func _effect_text() -> String:
	var text := "Villain attacks for %d damage" % damage
	if ignores_armor:
		text += ", ignoring armor"
	return text
