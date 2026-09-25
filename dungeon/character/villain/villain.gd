class_name Villain
extends Character

enum Symbol { NONE, SKULL, OMEGA, HEART }

const VILLAIN_CARDS: PackedScene = preload("uid://cs4gqthniprqk")

var current_symbol: Symbol
var _VillainCardsUI: VillainCardsUI

@export var mana: int
@export var max_mana: int
@export var second_phase_min: int
@export var second_phase_max: int
@export var symbol_bonuses: Array[SymbolBonus]
@export var immune_to_damage: bool = false
@export var symbol_count: Dictionary[Symbol, int] = {
	Symbol.SKULL: 0,
	Symbol.OMEGA: 0,
	Symbol.HEART: 0
	}
## Implement as a coroutine because the combat loop
## structure is awaiting for this method:
func prepare() -> VillainCardsUI:
	deck.prepare()
	_VillainCardsUI = VILLAIN_CARDS.instantiate() as VillainCardsUI
	_VillainCardsUI.prepare(deck, self)
	character_stats_changed.connect(_VillainCardsUI._update_counters)
	for count in symbol_count:
		count = 0
	statuses.clear()
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
	await _VillainCardsUI.change_current_symbol(new_symbol)


func complete_symbol(new_symbol: Symbol) -> void:
	await _VillainCardsUI.change_completed_symbol(new_symbol)


func resolve_symbol_bonus() -> void:
	for symbol_bonus in symbol_bonuses:
		if symbol_bonus.symbol == current_symbol:
			for bonus in symbol_bonus.bonuses:
				bonus.on_clash(GameManager.villain, GameManager.hero)
	symbol_count[current_symbol] += 1
	character_stats_changed.emit()
	await GameManager.get_tree().create_timer(GameManager.ux_delay).timeout


func is_in_second_phase() -> bool:
	return true if (health >= second_phase_min and health <= second_phase_max) else false


func end_phase() -> void:
	speed_bonus = 0
	for modifier in attack_modifiers:
		modifier.spend_use()
	GameManager.is_current_villain_card_enabled =  true


func take_damage(damage: int, ignores_armor: bool = false) -> void:
	var incoming_damage := damage
	health -= incoming_damage
	GameManager.add_log("Villain suffers %s damage" % str(incoming_damage))
	character_stats_changed.emit()
	

func take_attack(attack: Attack) -> void:
	if immune_to_damage:
		return
	take_damage(attack.damage, attack.ignores_armor)


func perform_attack(target: Character, damage: int = 0, ignores_armor: bool = false) -> void:
	var new_attack: Attack = Attack.new(target, damage, ignores_armor)
	for modifier in attack_modifiers:
		modifier.modify_attack(new_attack)
	target.take_attack(new_attack)
	GameManager.add_log("Villain attacks %s for %s with pierce %s" % [target.character_name, str(damage), str(ignores_armor)])


func heal(amount_to_heal: int) -> void:
	health += amount_to_heal
	character_stats_changed.emit()
	GameManager.add_log("Villain heals for %s" % [str(amount_to_heal)])


func get_bonus_speed(_bonus_speed: int) -> void:
	speed_bonus += _bonus_speed
	GameManager.add_log("Villain gets bonus speed for %s" % [str(_bonus_speed)])
