class_name AuditReport
extends RefCounted

var entries: Array[AuditLogEntry] = []


func add(line: String, source: AuditLogEntry.Source) -> void:
	entries.append(AuditLogEntry.new(line, source))


func append(outcome: AuditOutcome) -> void:
	for event: AuditEvent in outcome.events:
		add(_format_event(event), event.source)


func clear() -> void:
	entries.clear()


func _format_event(event: AuditEvent) -> String:
	match event.kind:
		AuditEvent.Kind.ATTACK:
			return "Attacks %s for %s with pierce %s" % [event.target, str(event.amount), str(event.flag)]
		AuditEvent.Kind.DAMAGE_ABSORBED:
			return "Armor absorbed %s damage" % str(event.amount)
		AuditEvent.Kind.DAMAGE_SUFFERED:
			return "Suffered %s damage" % str(event.amount) if event.source == AuditLogEntry.Source.HERO else "Suffers %s damage" % str(event.amount)
		AuditEvent.Kind.IMMUNITY_RESISTED:
			return "Hero resists damage due to immunity"
		AuditEvent.Kind.MAX_ARMOR_INCREASED:
			return "Increases max armor by %s" % str(event.amount)
		AuditEvent.Kind.MAX_HEALTH_INCREASED:
			return "Increases max health by %s" % str(event.amount)
		AuditEvent.Kind.MAX_DAMAGE_INCREASED:
			return "Increases max basic damage by %s" % str(event.amount)
		AuditEvent.Kind.HEALED:
			return "Heals for %s" % str(event.amount)
		AuditEvent.Kind.BONUS_SPEED_CHANGED:
			return "Gets %s bonus speed" % str(event.amount) if event.source == AuditLogEntry.Source.HERO else "Gets bonus speed for %s" % str(event.amount)
		AuditEvent.Kind.ARMOR_CHANGED:
			return "Changed armor to %s" % str(event.amount)
		AuditEvent.Kind.STATUS_TAKEN:
			return "Took a %s status" % event.subject
		AuditEvent.Kind.STATUS_TICKED:
			return "Ticked %s status" % event.subject
		AuditEvent.Kind.COMBAT_MODIFIER_TAKEN:
			return "Got a combat modifier"
		AuditEvent.Kind.CARD_PLAYED:
			return "Played %s" % event.subject
		AuditEvent.Kind.EMPTY_DECK_PENALTY:
			return "No cards left, take damage and reshuffle"
		AuditEvent.Kind.CARDS_RECOVERED:
			return "Takes %s cards from the discard" % str(event.amount)
		AuditEvent.Kind.CARDS_DISCARDED:
			return "Discards %s cards" % str(event.amount)
		AuditEvent.Kind.SYMBOL_BONUS_RESOLVED:
			return "Resolves %s bonus effect" % event.subject
		AuditEvent.Kind.STANCE_BONUS_TRIGGERED:
			return "Stance bonus effects triggered!"
		AuditEvent.Kind.SECOND_PHASE_BONUS_TRIGGERED:
			return "2nd Phase bonus effects triggered!:"
		AuditEvent.Kind.CARD_CANCELLED:
			return "Hero card is cancelled!" if event.source == AuditLogEntry.Source.HERO else "Villain card is cancelled!"
		AuditEvent.Kind.CARD_SKIPPED:
			return "CANCELLED!:" if event.flag else "CANCELLED!"
		AuditEvent.Kind.CARD_RESOLUTION_SEPARATOR:
			return "------------------"
		AuditEvent.Kind.CARD_RESOLVING:
			return "Resolve %s" % event.subject
		AuditEvent.Kind.HERO_DEFEATED:
			return "Hero defeated!"
		AuditEvent.Kind.PLAYER_LOST:
			return "Player lost"
	return ""
