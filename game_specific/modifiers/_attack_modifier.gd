@abstract class_name AttackModifier
extends RefCounted

signal attack_modifier_depleted(attack_modifier: AttackModifier)


var damage_modification: int
var ignores_armor: bool
var uses_left: int = 1:
	set(_uses_left):
		uses_left = _uses_left
		if uses_left <= 0:
			attack_modifier_depleted.emit(self)


func _init(_uses_left: int = 1, _damage_modification: int = 0, _ignores_armor: bool = false) -> void:
	damage_modification = _damage_modification
	ignores_armor = _ignores_armor
	uses_left = _uses_left

@abstract func modify_attack(attack: Attack) -> void
	
func spend_use() -> void:
	uses_left -= 1


func create_state_copy() -> AttackModifier:
	var copy := get_script().new() as AttackModifier
	copy.damage_modification = damage_modification
	copy.ignores_armor = ignores_armor
	copy.uses_left = uses_left
	return copy
