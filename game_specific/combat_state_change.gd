@abstract class_name CombatStateChange
extends RefCounted

enum Recipient { OWNER, OPPONENT }

var recipient: int = Recipient.OPPONENT


func _init(_recipient: int = Recipient.OPPONENT) -> void:
	recipient = _recipient


class AddStatus:
	extends CombatStateChange

	var status: Status

	func _init(_recipient: int, _status: Status) -> void:
		super(_recipient)
		status = _status


class RemoveStatuses:
	extends CombatStateChange

	var status_name: String

	func _init(_recipient: int, _status_name: String) -> void:
		super(_recipient)
		status_name = _status_name


class AddSpeedBonus:
	extends CombatStateChange

	var amount: int

	func _init(_recipient: int, _amount: int) -> void:
		super(_recipient)
		amount = _amount


class ClearSpeedBonus:
	extends CombatStateChange

	func _init(_recipient: int) -> void:
		super(_recipient)


class AddAttackModifier:
	extends CombatStateChange

	var modifier: AttackModifier

	func _init(_recipient: int, _modifier: AttackModifier) -> void:
		super(_recipient)
		modifier = _modifier


class RemoveAttackModifier:
	extends CombatStateChange

	var modifier: AttackModifier

	func _init(_recipient: int, _modifier: AttackModifier) -> void:
		super(_recipient)
		modifier = _modifier


class CancelSelectedCard:
	extends CombatStateChange

	func _init(_recipient: int) -> void:
		super(_recipient)
