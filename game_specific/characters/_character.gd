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


func save_turn_state() -> Dictionary:
	var status_states: Array[Status] = []
	for status: Status in statuses:
		status_states.append(status.duplicate(true) as Status)
	var modifier_states: Array[Dictionary] = []
	for modifier: AttackModifier in attack_modifiers:
		modifier_states.append(modifier.save_turn_state())
	return {
		"character_name": character_name,
		"max_health": max_health,
		"health": health,
		"speed_bonus": speed_bonus,
		"deck": deck.save_turn_state(),
		"statuses": status_states,
		"attack_modifiers": modifier_states,
	}


func restore_turn_state(state: Dictionary) -> void:
	character_name = state["character_name"]
	max_health = state["max_health"]
	health = state["health"]
	speed_bonus = state["speed_bonus"]
	deck.restore_turn_state(state["deck"])
	statuses.clear()
	for status: Status in state["statuses"]:
		var restored_status := status.duplicate(true) as Status
		statuses.append(restored_status)
		restored_status.status_depleted.connect(remove_status)
	attack_modifiers.clear()
	for modifier_state: Dictionary in state["attack_modifiers"]:
		var modifier := AttackModifier.from_turn_state(modifier_state)
		attack_modifiers.append(modifier)
		modifier.attack_modifier_depleted.connect(remove_attack_modifier)
	character_stats_changed.emit()
	modifiers_changed.emit()
