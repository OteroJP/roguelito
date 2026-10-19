@tool
class_name VillainTakeFromDiscard
extends Effect

@export_range(1, 20, 1) var cards_to_recover: int = 1

var _selected_cards: Array[CardData] = []
var _should_recover: bool = false


func _ask_for_interaction(
	villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	_selected_cards.clear()
	_should_recover = false
	var villain := villain_port.get_character()
	var available_count := villain.deck.cards_in_discard()
	var count := mini(maxi(cards_to_recover, 0), available_count)
	_should_recover = count > 0
	if _should_recover:
		_selected_cards = await villain_port.choose_cards_from_discard(
			villain.deck.display_discard_pile(), count
		)
	return outcome


func _on_clash(
	villain: Villain,
	_hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> AuditOutcome:
	if not _should_recover:
		return AuditOutcome.new()
	return villain.take_cards_from_discard(_selected_cards)


func _effect_text() -> String:
	return "Villain takes %d cards from the discard" % cards_to_recover
