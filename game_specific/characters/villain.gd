class_name Villain
extends Character

enum Symbol { NONE, SKULL, OMEGA, HEART }

signal current_symbol_changed(symbol: Symbol)
signal symbol_completed(symbol: Symbol)

var current_symbol: Symbol = Symbol.NONE:
	set(value):
		current_symbol = value
		current_symbol_changed.emit(value)

@export var mana: int
@export var max_mana: int
@export var second_phase_min: int
@export var second_phase_max: int
@export var immune_to_damage: bool = false
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


func draw() -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if not deck.may_draw(1): # Si no le quedan cartas, pierde 1 de vida, mezcla su descarte en un nuevo mazo y roba.
		deck.reshuffle()
		outcome.append(take_damage(1))
		outcome.add(AuditEvent.Kind.EMPTY_DECK_PENALTY, AuditLogEntry.Source.VILLAIN)
	deck.draw()
	return outcome


func create_state_copy() -> Villain:
	var copy := super.create_state_copy() as Villain
	copy.current_symbol = current_symbol
	copy.mana = mana
	copy.max_mana = max_mana
	copy.second_phase_min = second_phase_min
	copy.second_phase_max = second_phase_max
	copy.immune_to_damage = immune_to_damage
	copy.symbol_count = symbol_count.duplicate()
	return copy


func restore_villain_state_from(source: Villain) -> void:
	mana = source.mana
	max_mana = source.max_mana
	second_phase_min = source.second_phase_min
	second_phase_max = source.second_phase_max
	immune_to_damage = source.immune_to_damage
	current_symbol = source.current_symbol
	symbol_count = source.symbol_count.duplicate()
	restore_character_state_from(source)


func resolve_spell(spell: VillainSpell) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	assert(spell.mana_cost <= mana, "Insufficient mana to cast, spell should've been disabled.")
	mana -= spell.mana_cost
	for effect in spell.effects:
		outcome.append(await effect.on_clash(self, GameManager.hero))
	return outcome


func is_in_second_phase() -> bool:
	return true if (health >= second_phase_min and health <= second_phase_max) else false


func take_cards_from_discard(cards: Array[CardData]) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	deck.take_from_discard(cards)
	outcome.add(AuditEvent.Kind.CARDS_RECOVERED, AuditLogEntry.Source.VILLAIN, cards.size())
	return outcome


func discard_from_hand(cards: Array[CardData]) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	for card: CardData in cards:
		deck.discard(card)
	outcome.add(AuditEvent.Kind.CARDS_DISCARDED, AuditLogEntry.Source.VILLAIN, cards.size())
	return outcome


func take_damage(damage: int, ignores_armor: bool = false) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var incoming_damage := damage
	health -= incoming_damage
	outcome.add(AuditEvent.Kind.DAMAGE_SUFFERED, AuditLogEntry.Source.VILLAIN, incoming_damage)
	return outcome


func take_attack(attack: Attack) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if immune_to_damage:
		return outcome
	return take_damage(attack.damage, attack.ignores_armor)


func heal(amount_to_heal: int) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	health = min((health + amount_to_heal), max_health)
	amount_to_heal
	outcome.add(AuditEvent.Kind.HEALED, AuditLogEntry.Source.VILLAIN, amount_to_heal)
	return outcome
