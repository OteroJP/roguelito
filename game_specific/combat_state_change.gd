class_name CombatStateChange
extends RefCounted

enum Recipient { OWNER, OPPONENT }

var recipient: int = Recipient.OPPONENT
var statuses_to_add: Array[Status] = []
var statuses_to_remove: Array[String] = []
var modifiers_to_add: Array[AttackModifier] = []
var modifiers_to_remove: Array[AttackModifier] = []
var speed_bonus_to_add: int = 0
var clear_speed_bonuses: bool = false
var cancel_card: bool = false


func _init(_recipient: int = Recipient.OPPONENT) -> void:
	recipient = _recipient
