@abstract class_name CardData
extends Resource


@export var name: String
@export var art: Texture2D
@export var effect: Array[CardEffect]
@export var effect_bonus: Array[CardEffect]


func effects_text() -> String:
	var text: String = ""
	for card_effect in effect:
		text += card_effect.text() + "\n"
	return text.strip_edges()
