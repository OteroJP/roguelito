class_name Villain extends Character

enum Symbol { NONE, SKULL, OMEGA, HEART }

const VILLAIN_CARDS: PackedScene = preload("uid://cs4gqthniprqk")

var current_symbol: Symbol
var _VillainCardsUI: VillainCardsUI

@export var mana: int
@export var max_mana: int
@export var second_phase_min: int
@export var second_phase_max: int


## Implement as a coroutine because the combat loop
## structure is awaiting for this method:
func prepare() -> VillainCardsUI:
	deck.prepare()
	_VillainCardsUI = VILLAIN_CARDS.instantiate() as VillainCardsUI
	_VillainCardsUI.prepare(deck, self)
	character_stats_changed.connect(_VillainCardsUI._update_counters)
	return _VillainCardsUI
	
	
func play_card() -> void: #CardData
	var card: CardData = await _VillainCardsUI.choose_card()
	deck.play(card)
	await _VillainCardsUI.remove_from_hand(card)
	await GameManager.play_villain_card(card)


func draw() -> void:
	if not deck.may_draw(1): # Si no le quedan cartas, pierde 1 de vida, mezcla su descarte en un nuevo mazo y roba.
		deck.reshuffle()
		take_damage(1)
	var card_data: CardData = deck.draw()
	await _VillainCardsUI.add_to_hand([card_data])

	
func show_hand() -> void:
	#TESTING
	await _VillainCardsUI.add_to_hand(deck.display_hand())
	
	
func activate_ability() -> void:
	pass
	

func matches_current_symbol(symbol_to_match: Symbol) -> bool:
	return true if symbol_to_match == current_symbol else false	

	
func change_symbol(new_symbol: Symbol) -> void:
	current_symbol = new_symbol


func resolve_symbol_bonus() -> void:
	pass
	

func is_in_second_phase() -> bool:
	return true if (health >= second_phase_min and health <= second_phase_max) else false
