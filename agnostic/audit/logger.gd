class_name GameLogger
extends Node

const _LOG_COLOR: Dictionary[AuditLogEntry.Source, String] = {
	AuditLogEntry.Source.HERO: "#8ec8ff",
	AuditLogEntry.Source.VILLAIN: "#ff7a7a",
	AuditLogEntry.Source.GAME: "#f0d078",
}
const _LOG_TAG: Dictionary[AuditLogEntry.Source, String] = {
	AuditLogEntry.Source.HERO: "HERO",
	AuditLogEntry.Source.VILLAIN: "VILLAIN",
	AuditLogEntry.Source.GAME: "GAME",
}

var _combat_log: CombatLog


func _ready() -> void:
	_combat_log = CombatLog.new()
	add_child(_combat_log)
	_combat_log.set_legend(
		"[color=%s]HERO[/color]   [color=%s]VILLAIN[/color]   [color=%s]GAME[/color]    F1 toggles" % [
			_LOG_COLOR[AuditLogEntry.Source.HERO],
			_LOG_COLOR[AuditLogEntry.Source.VILLAIN],
			_LOG_COLOR[AuditLogEntry.Source.GAME],
		]
	)


func display_report(report: AuditReport) -> void:
	var formatted_report := ""
	for entry in report.entries:
		formatted_report += _format_entry(entry.line, entry.source)
	_combat_log.append_report(formatted_report)


func display_entry(entry: AuditLogEntry) -> void:
	_combat_log.append_report(_format_entry(entry.line, entry.source))


func display_phase_header(header: String) -> void:
	var formatted_header := _format_entry("-------", AuditLogEntry.Source.GAME)
	formatted_header += _format_entry(header, AuditLogEntry.Source.GAME)
	_combat_log.append_report(formatted_header)


func display_cycle_header(round_number: int) -> void:
	var formatted_header := _format_entry("---------------------------", AuditLogEntry.Source.GAME)
	formatted_header += _format_entry("Round %d" % round_number, AuditLogEntry.Source.GAME)
	_combat_log.append_report(formatted_header)
	_combat_log.make_last_turn()


func erase_last_turn() -> void:
	_combat_log.erase_last_turn()


func log(line: String, source: AuditLogEntry.Source = AuditLogEntry.Source.GAME) -> void:
	_combat_log.append_report(_format_entry(line, source))


func clear() -> void:
	_combat_log.clear()


func _format_entry(line: String, source: AuditLogEntry.Source) -> String:
	var safe_line := line.replace("[", "[lb]")
	return "[color=%s][lb]%s[rb] %s[/color]\n" % [
		_LOG_COLOR[source],
		_LOG_TAG[source],
		safe_line,
	]
