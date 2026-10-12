@abstract class_name Character
extends Resource

signal character_stats_changed
signal modifiers_changed

@export var character_name: String
@export var max_health: int
@export var health: int
@export var deck: Deck
var statuses: Array[Status]
var attack_modifiers: Array[AttackModifier]

var speed_bonus: int


func create_state_copy() -> Character:
	var copy := duplicate() as Character
	copy.character_name = character_name
	copy.max_health = max_health
	copy.health = health
	copy.deck = deck.create_state_copy() if deck != null else null
	copy.statuses.clear()
	for status: Status in statuses:
		copy.statuses.append(status.duplicate(true) as Status)
	copy.attack_modifiers.clear()
	for modifier: AttackModifier in attack_modifiers:
		copy.attack_modifiers.append(modifier.create_state_copy())
	copy.speed_bonus = speed_bonus
	return copy


@abstract func prepare() -> Node

@abstract func play_card() -> AuditOutcome

@abstract func draw() -> AuditOutcome

@abstract func end_phase() -> AuditOutcome

@abstract func take_damage(damage: int, ignores_armor: bool) -> AuditOutcome


@abstract func take_attack(attack: Attack) -> AuditOutcome


@abstract func perform_attack(target: Character, damage: int = 0, ignores_armor: bool = false) -> AuditOutcome

@abstract func heal(amount_to_heal: int) -> AuditOutcome


@abstract func take_attack_modifier(modifier: AttackModifier) -> AuditOutcome

@abstract func remove_attack_modifier(modifier: AttackModifier) -> void

@abstract func tick_statuses(villain: Villain, hero: Hero) -> AuditOutcome


@abstract func take_status(status: Status) -> AuditOutcome


func remove_status(status_to_remove: Status) -> void:
	statuses.erase(status_to_remove)
	#Entiendo que siendo q son ref counted no necesitan free


func restore_character_state_from(source: Character) -> void:
	character_name = source.character_name
	max_health = source.max_health
	health = source.health
	if source.deck == null:
		deck = null
	elif deck == null:
		deck = source.deck.create_state_copy()
	else:
		deck.restore_state_from(source.deck)
	statuses.clear()
	for status: Status in source.statuses:
		var restored_status := status.duplicate(true) as Status
		statuses.append(restored_status)
		restored_status.status_depleted.connect(remove_status)
	attack_modifiers.clear()
	for modifier: AttackModifier in source.attack_modifiers:
		var restored_modifier := modifier.create_state_copy()
		attack_modifiers.append(restored_modifier)
		restored_modifier.attack_modifier_depleted.connect(remove_attack_modifier)
	speed_bonus = source.speed_bonus
	character_stats_changed.emit()
	modifiers_changed.emit()
