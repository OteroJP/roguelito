class_name AuditOutcome
extends RefCounted

var events: Array[AuditEvent] = []


func add(
	kind: AuditEvent.Kind,
	source: AuditLogEntry.Source,
	amount: int = 0,
	subject: String = "",
	target: String = "",
	flag: bool = false
) -> void:
	events.append(AuditEvent.new(kind, source, amount, subject, target, flag))


func append(outcome: AuditOutcome) -> void:
	events.append_array(outcome.events)
