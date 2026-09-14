class_name Villain extends Character

const VILLAIN_CARDS: PackedScene = preload("uid://cs4gqthniprqk")

var _VillainCardsUI: VillainCardsUI

## Implement as a coroutine because the combat loop
## structure is awaiting for this method:
func create_node() -> VillainCardsUI:
	_VillainCardsUI = VILLAIN_CARDS.instantiate() as VillainCardsUI	
	return _VillainCardsUI
	
	
func play_card() -> void: #CardData
	var card: CardData = await _VillainCardsUI.choose_card()
	deck.play(card)
	GameManager.current_villain_card = card #return card


func draw() -> void:
	if not deck.may_draw(1):
		deck.reshuffle()
		take_damage(1)		
	var card_data: CardData = deck.draw()
	await _VillainCardsUI.add_to_hand([card_data])
