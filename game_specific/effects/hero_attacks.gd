class_name HeroAttacks
extends Effect

@export var damage: int
@export var ignores_armor: bool = false

func on_clash(villain: Villain, hero: Hero):
	hero.perform_attack(villain, damage, ignores_armor)
