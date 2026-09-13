class_name DamageEffect
extends CardEffect

@export var damage: int

func on_play():
	pass


func on_resolve():
	if character_target:
		character_target.take_damage(damage)


func on_discard():
	pass
