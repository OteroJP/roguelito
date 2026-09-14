@abstract class_name Character
extends Resource

@export var character_name: String
@export var deck: Deck
@export var discard: Array[CardData]
@export var hand: Array[CardData]
@export var max_health: int
@export var health: int


@abstract func create_node() -> Node


## Implement as a coroutine because the combat loop
## structure is awaiting for this method
@abstract func play_card() -> void


func take_damage(damage: int) -> void:
	health -= damage
