class_name AuditEvent
extends RefCounted

enum Kind {
	ATTACK,
	DAMAGE_ABSORBED,
	DAMAGE_SUFFERED,
	IMMUNITY_RESISTED,
	MAX_ARMOR_INCREASED,
	MAX_HEALTH_INCREASED,
	MAX_DAMAGE_INCREASED,
	HEALED,
	BONUS_SPEED_CHANGED,
	ARMOR_CHANGED,
	STATUS_TAKEN,
	STATUS_TICKED,
	COMBAT_MODIFIER_TAKEN,
	CARD_PLAYED,
	EMPTY_DECK_PENALTY,
	CARDS_RECOVERED,
	CARDS_DISCARDED,
	SYMBOL_BONUS_RESOLVED,
	STANCE_BONUS_TRIGGERED,
	SECOND_PHASE_BONUS_TRIGGERED,
	CARD_CANCELLED,
	CARD_SKIPPED,
	CARD_RESOLUTION_SEPARATOR,
	CARD_RESOLVING,
	HERO_DEFEATED,
	PLAYER_LOST,
}

var kind: Kind
var source: AuditLogEntry.Source
var amount: int
var subject: String
var target: String
var flag: bool


func _init(
	event_kind: Kind,
	event_source: AuditLogEntry.Source,
	event_amount: int = 0,
	event_subject: String = "",
	event_target: String = "",
	event_flag: bool = false
) -> void:
	kind = event_kind
	source = event_source
	amount = event_amount
	subject = event_subject
	target = event_target
	flag = event_flag
