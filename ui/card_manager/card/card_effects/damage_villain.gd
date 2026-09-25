class_name DamageVillain
extends CardEffect

@export var damage: int

#TODO refactor to new attack system
func on_clash(villain: Villain, hero: Hero):
	villain.take_damage(damage)
