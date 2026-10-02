class_name VillainHeal
extends Effect

@export var amount_to_heal: int

#TODO refactor to new attack system
func on_clash(villain: Villain, hero: Hero):
	villain.heal(amount_to_heal)
