class_name Character
extends Node

var character_blueprint: CharacterBlueprint
var character_state: CharacterState


func _init(_blueprint: CharacterBlueprint) -> void:
	character_state = CharacterState.new(_blueprint)
	character_state.health = character_state.max_health
	

func take_damage(damage: int):
	health -= damage


func play_card(card: Card):
	remove_from_hand(card)
	card_played.emit(card)
	
	
func draw_card():


	
