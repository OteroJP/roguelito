@tool
class_name HeroRemoveStatus
extends Effect

@export var status_to_remove: Status

func on_clash(villain: Villain, hero: Hero):
	for status in hero.statuses:
		if status.name == status_to_remove.name:
			hero.remove_status(status)

func _effect_text() -> String:
	return "Hero removes all %s statuses" % status_to_remove.name
