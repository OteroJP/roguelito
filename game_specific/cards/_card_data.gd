@abstract class_name CardData
extends Resource

signal resolved(card: CardData)

@export var name: String
@export_multiline() var effect_text: String
@export var art: Texture2D
@export var speed: int
@export var bonus_effects: Array[Effect]
@export var effects: Array[Effect]


func effects_text() -> String:
	var text: String = ""
	for effect in effects:
		text += effect.text() + "\n"
	return text.strip_edges()


@abstract func on_play(villain: Villain, hero: Hero)


@abstract func on_clash(villain: Villain, hero: Hero)


@abstract func after_clash(villain: Villain, hero: Hero)


@abstract func on_discard(villain: Villain, hero: Hero)
