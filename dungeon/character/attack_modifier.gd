class_name AttackModifier
extends RefCounted

signal attack_modifier_depleted(attack_modifier: AttackModifier)

var target: Character
var damage_modification: int
var ignores_armor: bool
var uses_left: int = 1:
	set(_uses_left):
		uses_left = _uses_left
		if uses_left <= 0:
			attack_modifier_depleted.emit(self)


func modify_attack(attack: Attack) -> void:
	attack.target = target
	attack.damage += damage_modification
	attack.ignores_armor = ignores_armor
	
	
func spend_use() -> void:
	uses_left -= 1
