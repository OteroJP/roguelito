@tool
class_name VillainTakeFromDiscard
extends Effect

@export_range(1, 20, 1) var cards_to_recover: int = 1



func prepare(effect_owner_port: CharacterPort) -> void:
	var villain_port := effect_owner_port as VillainPort
	assert(villain_port != null, "VillainTakeFromDiscard requires a Villain port.")
	await villain_port.take_cards_from_discard(cards_to_recover)


func _effect_text() -> String:
    return "Villain takes %d cards from the discard" % cards_to_recover
