class_name DamageHero
extends CardEffect

@export var damage: int


func on_clash(villain: Villain, hero: Hero):
	hero.take_damage(damage)
