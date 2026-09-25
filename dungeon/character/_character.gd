@abstract class_name Character
extends Resource

signal character_stats_changed

@export var character_name: String
@export var max_health: int
@export var health: int
@export var deck: Deck
var statuses: Array[Status]
var attack_modifiers: Array[AttackModifier]

var speed_bonus: int

@abstract func prepare() -> Node

@abstract func play_card() -> void

@abstract func draw() -> void

@abstract func end_phase() -> void

@abstract func take_damage(damage: int, ignores_armor: bool) -> void

@abstract func take_attack(attack: Attack) -> void
	
@abstract func perform_attack(target: Character, damage: int = 0, ignores_armor: bool = false) -> void
	
@abstract func heal(amount_to_heal: int) -> void


func take_attack_modifier(modifier: AttackModifier) -> void:
	attack_modifiers.append(modifier)
	modifier.attack_modifier_depleted.connect(remove_attack_modifier)
	
	
func remove_attack_modifier(modifier: AttackModifier) -> void:
	attack_modifiers.erase(modifier)
	#Entiendo que siendo q son ref counted no necesitan free


func tick_statuses(villain: Villain, hero: Hero) -> void:
	for status in statuses:
		status.on_tick(villain, hero)
		
		
func take_status(status: Status) -> void:
	var new_status: Status = status.duplicate(true)
	statuses.append(new_status)
	new_status.status_depleted.connect(remove_status)
	
	
func remove_status(status_to_remove: Status) -> void:
	statuses.erase(status_to_remove)
	#Entiendo que siendo q son ref counted no necesitan free
	
