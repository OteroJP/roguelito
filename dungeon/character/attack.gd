class_name Attack
extends RefCounted

var target: Character
var damage: int
var ignores_armor: bool


func _init(_target: Character, _damage: int, _ignores_armor: bool) -> void:
	target = _target
	damage = _damage
	ignores_armor = _ignores_armor
