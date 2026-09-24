class_name HealHero
extends CardEffect

@export var amount_to_heal: int


func on_clash(villain: Villain, hero: Hero):
	hero.heal(amount_to_heal)
