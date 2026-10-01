@abstract class_name CardEffect
extends Resource

#this is unsuitable to then resolve the actual target
#split between different subclasses of card effects
#then ask for class
@export_multiline() var effect_text: String = "Lorem ipsum"


func on_play(villain: Villain, hero: Hero):
	pass


func on_clash(villain: Villain, hero: Hero):
	pass


func after_clash(villain: Villain, hero: Hero):
	pass


func on_discard(villain: Villain, hero: Hero):
	pass
	

func text() -> String:
	return effect_text


#DamageEffect
#extends CardEffect
#var damage: int
#func _on_clash(_target)
	#if  _get_target() and  _get_target().has_metod(“take_damage”):
		#target.take_damage(damage)
