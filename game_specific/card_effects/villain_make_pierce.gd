class_name VillainPierce
extends CardEffect

func on_clash(villain: Villain, hero: Hero):
	var pierce_modifier: PierceModifier = PierceModifier.new()
	villain.take_attack_modifier(pierce_modifier)
