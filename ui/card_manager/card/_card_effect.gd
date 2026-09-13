@abstract class_name CardEffect
extends Resource

#this is unsuitable to then resolve the actual target
#split between different subclasses of card effects
#then ask for class
enum Target { NONE, VILLAIN, HERO, BOTH, CARD}
@export var _target: CardEffect.Target
var character_target: Character
var card_target: Card

func on_play():
	pass


func on_resolve():
	pass


func on_discard():
	pass



#DamageEffect
#extends CardEffect
#var damage: int
#func _on_resolve(_target)
	#if  _get_target() and  _get_target().has_metod(“take_damage”):
		#target.take_damage(damage)
