class_name CharacterState
extends Resource

var character_name: String
var deck: Array[CardData]
var discard: Array[CardData]
var hand
var max_health: int
var health: int


func _init(_blueprint: CharacterBlueprint) -> void:
	character_name = _blueprint.character_name
	deck = _blueprint.starting_deck
	max_health = _blueprint.max_health
	
