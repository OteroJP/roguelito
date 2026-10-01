class_name Status
extends RefCounted
## Use a duration of -1 for infinite statuses

signal status_depleted(status: Status)

@export var name: String
@export_multiline() var tooltip: String
@export var duration: int
@export var status_effects: Array[StatusEffect]

func on_tick(villain: Villain, hero: Hero) -> void:
	resolve_status_effects(villain, hero)
	if duration != -1:
		duration -= 1
		if duration <= 0:
			status_depleted.emit(self)


func resolve_status_effects(villain: Villain, hero: Hero):
	for effect in status_effects:
		effect.on_tick(villain, hero)
