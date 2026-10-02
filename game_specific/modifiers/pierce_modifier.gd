class_name PierceModifier
extends AttackModifier

func modify_attack(attack: Attack) -> void:
	attack.ignores_armor = true
