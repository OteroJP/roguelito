class_name VillainModifyDamage
extends CardEffect

@export var damage_modification: int = 1

func on_clash(villain: Villain, hero: Hero):
	var damage_modifier: DamageModifier = DamageModifier.new(1, damage_modification)
	villain.take_attack_modifier(damage_modifier)
