class_name PierceModifier
extends AttackModifier

func _init(_uses_left: int = 1) -> void:
	super(_uses_left, 0, true)


func modify_attack(attack: Attack) -> void:
	attack.ignores_armor = true
