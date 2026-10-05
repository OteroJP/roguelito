@tool
class_name VillainDraw
extends Effect

@export var cards_to_draw: int = 1


func on_clash(villain: Villain, hero: Hero) -> void:
	for i in cards_to_draw:
		villain.draw()


func _effect_text() -> String:
	return "Villain draws %d cards" % cards_to_draw
