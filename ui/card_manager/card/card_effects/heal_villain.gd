class_name HealVillain
extends CardEffect

@export var amount_to_heal: int


func on_clash(villain: Villain, hero: Hero):
	villain.heal(amount_to_heal)
