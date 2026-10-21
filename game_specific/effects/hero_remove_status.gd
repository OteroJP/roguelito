@tool
class_name HeroRemoveStatus
extends Effect

@export var status_to_remove: Status


func _on_clash(
	_villain: Villain,
	_hero: Hero,
	_villain_port: VillainPort,
	hero_port: HeroPort,
	combat_manager: CombatManager
) -> void:
	for status: Status in combat_manager.statuses_for(hero_port):
		if status.name == status_to_remove.name:
			combat_manager.remove_status(hero_port, status)



func _effect_text() -> String:
	return "Hero removes all %s statuses" % status_to_remove.name
