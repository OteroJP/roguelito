class_name DamageVillain
extends CardEffect

@export var damage: int


func on_clash(villain: Villain, hero: Hero):
	villain.take_damage(damage)
