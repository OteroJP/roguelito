class_name DamageHero
extends CardEffect

@export var damage: int

#TODO refactor to new attack system
func on_clash(villain: Villain, hero: Hero):
	hero.take_damage(damage)
