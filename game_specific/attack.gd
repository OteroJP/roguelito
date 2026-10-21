class_name Attack
extends RefCounted

var damage: int
var ignores_armor: bool


func _init(_damage: int, _ignores_armor: bool) -> void:
	damage = _damage
	ignores_armor = _ignores_armor
