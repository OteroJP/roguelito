class_name AuditLogEntry
extends RefCounted

enum Source { HERO, VILLAIN, GAME }

var line: String
var source: Source


func _init(message: String, log_source: Source) -> void:
	line = message
	source = log_source
