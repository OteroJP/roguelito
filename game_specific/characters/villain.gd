class_name Villain
extends Character

enum Symbol { NONE, SKULL, OMEGA, HEART }

var current_symbol: Symbol = Symbol.NONE

@export var mana: int
@export var max_mana: int
@export var second_phase_min: int
@export var second_phase_max: int
@export var symbol_bonuses: Array[SymbolBonus]
@export var spells: Array[VillainSpell]
@export var symbol_count: Dictionary[Symbol, int] = {
	Symbol.SKULL: 0,
	Symbol.OMEGA: 0,
	Symbol.HEART: 0
	}


func prepare() -> void:
	super.prepare()
	for symbol in symbol_count:
		symbol_count[symbol] = 0


func draw() -> void:
	if not deck.may_draw(1): # Si no le quedan cartas, pierde 1 de vida, mezcla su descarte en un nuevo mazo y roba.
		deck.reshuffle()
		take_damage(1)
	deck.draw()


func create_state_copy() -> Villain:
	var copy := super.create_state_copy() as Villain
	copy.current_symbol = current_symbol
	copy.mana = mana
	copy.max_mana = max_mana
	copy.second_phase_min = second_phase_min
	copy.second_phase_max = second_phase_max
	copy.symbol_count = symbol_count.duplicate()
	return copy


func restore_villain_state_from(source: Villain) -> void:
	mana = source.mana
	max_mana = source.max_mana
	second_phase_min = source.second_phase_min
	second_phase_max = source.second_phase_max
	current_symbol = source.current_symbol
	symbol_count = source.symbol_count.duplicate()
	restore_character_state_from(source)


func spend_mana(amount: int) -> void:
	assert(amount <= mana, "Insufficient mana to cast, spell should've been disabled.")
	mana -= amount


func is_in_second_phase() -> bool:
	return true if (health >= second_phase_min and health <= second_phase_max) else false


func take_cards_from_discard(cards: Array[CardData]) -> void:
	deck.take_from_discard(cards)


func discard_from_hand(cards: Array[CardData]) -> void:
	for card: CardData in cards:
		deck.discard(card)


func take_damage(damage: int, ignores_armor: bool = false) -> void:
	var incoming_damage := damage
	health -= incoming_damage


func take_attack(attack: Attack) -> void:
	if immune_to_damage:
		return
	take_damage(attack.damage, attack.ignores_armor)


func heal(amount_to_heal: int) -> void:
	health = min((health + amount_to_heal), max_health)
