@abstract class_name CardEffect
extends Resource

enum Target { SELF, ENEMY , BOTH, CARD}

@export var _play_conditional: Conditional
@export var _resolve_conditional: Conditional
@export var _discard_conditional: Conditional
@export var _target: Target

func _get_target() -> Character:
	return game_manager.get_target(_target)

func _on_play() -> void:
	if not _play_conditional or _play_conditional == null:
		pass

func _on_resolve() -> void:
	pass

func _on_discard() -> void:
	pass




#DamageEffect
#extends CardEffect
#var damage: int
#func _on_resolve(_target)
	#if  _get_target() and  _get_target().has_metod(“take_damage”):
		#target.take_damage(damage)
