class_name DamageModifier
extends AttackModifier

func modify_attack(attack: Attack) -> void:
	attack.damage += damage_modification
