class_name CardData
extends Resource

signal resolved

@export var name: String
@export_multiline() var effect_text: String
@export var art: Texture2D
@export var speed: int
@export var effects: Array[CardEffect]
@export var bonus_effects: Array[CardEffect]


func effects_text() -> String:
	var text: String = ""
	for card_effect in effects:
		text += card_effect.text() + "\n"
	return text.strip_edges()
