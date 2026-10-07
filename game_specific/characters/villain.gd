class_name Villain
extends Character

enum Symbol { NONE, SKULL, OMEGA, HEART }

const VILLAIN_CARDS: PackedScene = preload("uid://cs4gqthniprqk")

var current_symbol: Symbol
var _VillainVisuals: VillainVisuals

@export var mana: int
@export var max_mana: int
@export var second_phase_min: int
@export var second_phase_max: int
@export var symbol_bonuses: Array[SymbolBonus]
@export var spells: Array[VillainSpell]
@export var immune_to_damage: bool = false
@export var symbol_count: Dictionary[Symbol, int] = {
	Symbol.SKULL: 0,
	Symbol.OMEGA: 0,
	Symbol.HEART: 0
	}
## Implement as a coroutine because the combat loop
## structure is awaiting for this method:


func prepare() -> VillainVisuals:
	deck.prepare()
	_VillainVisuals = VILLAIN_CARDS.instantiate() as VillainVisuals
	_VillainVisuals.prepare(deck, self)
	character_stats_changed.connect(_VillainVisuals._update_counters)
	for count in symbol_count:
		count = 0
	statuses.clear()
	return _VillainVisuals


func play_card() -> AuditOutcome: #CardData
	var outcome := AuditOutcome.new()
	var card: CardData = await _VillainVisuals.choose_card()
	deck.play(card)
	await _VillainVisuals.remove_from_hand(card)
	outcome.append(await GameManager.play_villain_card(card))
	outcome.add(AuditEvent.Kind.CARD_PLAYED, AuditLogEntry.Source.VILLAIN, 0, card.name)
	return outcome


func draw() -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if not deck.may_draw(1): # Si no le quedan cartas, pierde 1 de vida, mezcla su descarte en un nuevo mazo y roba.
		deck.reshuffle()
		outcome.append(take_damage(1))
		outcome.add(AuditEvent.Kind.EMPTY_DECK_PENALTY, AuditLogEntry.Source.VILLAIN)
	var card_data: CardData = deck.draw()
	await _VillainVisuals.add_to_hand([card_data])
	return outcome


func show_hand() -> void:
	#TESTING
	await _VillainVisuals.add_to_hand(deck.display_hand())


func cast_spells() -> AuditOutcome:
	return await _VillainVisuals.cast_spells()


func resolve_spell(spell: VillainSpell) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	assert(spell.mana_cost <= mana, "Insufficient mana to cast, spell should've been disabled.")
	mana -= spell.mana_cost
	for effect in spell.effects:
		outcome.append(await effect.on_clash(self, GameManager.hero))
	character_stats_changed.emit()
	return outcome


func matches_current_symbol(symbol_to_match: Symbol) -> bool:
	return true if symbol_to_match == current_symbol else false


func change_symbol(new_symbol: Symbol) -> void:
	current_symbol = new_symbol
	await _VillainVisuals.change_current_symbol(new_symbol)


func complete_symbol(new_symbol: Symbol) -> void:
	await _VillainVisuals.change_completed_symbol(new_symbol)


func resolve_symbol_bonus() -> AuditOutcome:
	var outcome := AuditOutcome.new()
	for symbol_bonus in symbol_bonuses:
		if symbol_bonus.symbol == current_symbol:
			outcome.add(AuditEvent.Kind.SYMBOL_BONUS_RESOLVED, AuditLogEntry.Source.VILLAIN, 0, Symbol.keys()[current_symbol])
			for bonus in symbol_bonus.bonuses:
				outcome.append(await bonus.on_clash(GameManager.villain, GameManager.hero))
	symbol_count[current_symbol] += 1
	character_stats_changed.emit()
	await GameManager.get_tree().create_timer(GameManager.ux_delay).timeout
	return outcome


func is_in_second_phase() -> bool:
	return true if (health >= second_phase_min and health <= second_phase_max) else false


func end_phase() -> AuditOutcome:
	var outcome := AuditOutcome.new()
	speed_bonus = 0
	for modifier in attack_modifiers.duplicate():
		modifier.spend_use()
	GameManager.is_current_villain_card_enabled =  true
	modifiers_changed.emit()
	outcome.append(await discard_from_hand(deck.cards_over_hand_limit()))
	return outcome


func take_cards_from_discard(amount: int) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var to_take := mini(maxi(amount, 0), deck.cards_in_discard())
	if to_take <= 0:
		return outcome
	var cards: Array[CardData] = await _VillainVisuals.choose_cards_from_discard(deck.display_discard_pile(), to_take)
	deck.take_from_discard(cards)
	await _VillainVisuals.add_to_hand(cards)
	outcome.add(AuditEvent.Kind.CARDS_RECOVERED, AuditLogEntry.Source.VILLAIN, cards.size())
	return outcome


func discard_from_hand(amount: int) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var to_discard := mini(maxi(amount, 0), deck.cards_in_hand())
	if to_discard <= 0:
		return outcome
	var cards: Array[CardData] = await _VillainVisuals.choose_cards(to_discard)
	for card: CardData in cards:
		deck.discard(card)
		_VillainVisuals.remove_from_hand(card)
	outcome.add(AuditEvent.Kind.CARDS_DISCARDED, AuditLogEntry.Source.VILLAIN, cards.size())
	return outcome


func take_damage(damage: int, ignores_armor: bool = false) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var incoming_damage := damage
	health -= incoming_damage
	outcome.add(AuditEvent.Kind.DAMAGE_SUFFERED, AuditLogEntry.Source.VILLAIN, incoming_damage)
	character_stats_changed.emit()
	return outcome


func take_attack(attack: Attack) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if immune_to_damage:
		return outcome
	return take_damage(attack.damage, attack.ignores_armor)


func perform_attack(target: Character, damage: int = 0, ignores_armor: bool = false) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var new_attack: Attack = Attack.new(target, damage, ignores_armor)
	for modifier in attack_modifiers:
		modifier.modify_attack(new_attack)
	outcome.add(AuditEvent.Kind.ATTACK, AuditLogEntry.Source.VILLAIN, damage, "", target.character_name, ignores_armor)
	outcome.append(target.take_attack(new_attack))
	return outcome


func heal(amount_to_heal: int) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	health = min((health + amount_to_heal), max_health)
	amount_to_heal
	character_stats_changed.emit()
	outcome.add(AuditEvent.Kind.HEALED, AuditLogEntry.Source.VILLAIN, amount_to_heal)
	return outcome


func get_bonus_speed(_bonus_speed: int) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	speed_bonus += _bonus_speed
	modifiers_changed.emit()
	outcome.add(AuditEvent.Kind.BONUS_SPEED_CHANGED, AuditLogEntry.Source.VILLAIN, _bonus_speed)
	return outcome


func take_status(status: Status) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var new_status: Status = status.duplicate(true)
	statuses.append(new_status)
	new_status.status_depleted.connect(remove_status)
	await _VillainVisuals.add_status(new_status)
	return outcome


func tick_statuses(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if statuses.is_empty():
		return outcome
	for status in statuses:
		outcome.add(AuditEvent.Kind.STATUS_TICKED, AuditLogEntry.Source.VILLAIN, 0, status.name)
		outcome.append(await status.on_tick(villain, hero))
	return outcome


func take_attack_modifier(modifier: AttackModifier) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	attack_modifiers.append(modifier)
	modifier.attack_modifier_depleted.connect(remove_attack_modifier)
	modifiers_changed.emit()
	return outcome


func remove_attack_modifier(modifier: AttackModifier) -> void:
	attack_modifiers.erase(modifier)
	modifiers_changed.emit()


func get_symbol_count(symbol: Villain.Symbol):
	if symbol == Symbol.NONE:
		return 0
	else:
		return symbol_count[symbol]
