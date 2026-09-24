@abstract class_name Character
extends Resource

signal character_stats_changed

@export var character_name: String
@export var max_health: int
@export var health: int
@export var deck: Deck


@abstract func prepare() -> Node

@abstract func play_card() -> void

@abstract func draw() -> void


func take_damage(damage: int) -> void:
	health -= damage
	character_stats_changed.emit()
	
	
func heal(amount_to_heal: int) -> void:
	health += amount_to_heal
	character_stats_changed.emit()
