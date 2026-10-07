class_name AuditReport
extends RefCounted

var entries: Array[AuditLogEntry] = []


func add(line: String, source: AuditLogEntry.Source) -> void:
	entries.append(AuditLogEntry.new(line, source))


func clear() -> void:
	entries.clear()
