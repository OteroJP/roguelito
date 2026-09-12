@abstract class_name CardEffect
extends Resource

enum Target { NONE, SELF, ENEMY, BOTH, CARD}
@export var _target: CardEffect.Target

func _on_play():
	pass

func _on_resolve():
	pass

func _on_discard():
	pass


#DamageEffect
#extends CardEffect
#var damage: int
#func _on_resolve(_target)
	#if  _get_target() and  _get_target().has_metod(“take_damage”):
		#target.take_damage(damage)
