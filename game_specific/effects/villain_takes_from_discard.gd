@tool
class_name VillainTakeFromDiscard
extends Effect

@export_range(1, 20, 1) var cards_to_recover: int = 1


func on_clash(villain: Villain, hero: Hero) -> void:
	await villain.take_cards_from_discard(cards_to_recover)


func _effect_text() -> String:
	return "Villain takes %d cards from the discard" % cards_to_recover
