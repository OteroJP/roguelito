@abstract class_name StatusEffect
extends Resource

@export_multiline() var effect_text: String = "Lorem ipsum"


@abstract func on_tick(villain: Villain, hero: Hero)
	

func text() -> String:
	return effect_text
