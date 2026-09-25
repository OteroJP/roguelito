@abstract class_name Character
extends Resource

signal character_stats_changed

@export var character_name: String
@export var max_health: int
@export var health: int
@export var deck: Deck
@export var statuses: Array[Status]

var speed_bonus: int

@abstract func prepare() -> Node

@abstract func play_card() -> void

@abstract func draw() -> void

@abstract func end_phase() -> void

@abstract func take_damage(attack: Attack) -> void
	
	
func heal(amount_to_heal: int) -> void:
	health += amount_to_heal
	character_stats_changed.emit()


func tick_statuses(villain: Villain, hero: Hero) -> void:
	for status in statuses:
		status.on_tick(villain, hero)
		
		
func take_status(status: Status) -> void:
	var new_status: Status = status.duplicate(true)
	statuses.append(new_status)
	new_status.status_depleted.connect(remove_status)
	
	
func remove_status(status_to_remove: Status) -> void:
	statuses.erase(status_to_remove)
	status_to_remove.queue_free()
	
