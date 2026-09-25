class_name VillainAttack
extends CardEffect

@export var damage: int
@export var ignores_armor: bool = false

func on_clash(villain: Villain, hero: Hero):
	villain.perform_attack(hero, damage, ignores_armor)
