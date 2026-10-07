@abstract class_name LoopPhase extends RefCounted

#signal phase_ended

var _have_loop_ended: Callable
var _report: AuditReport = AuditReport.new()


func add_end_condition(cb: Callable) -> void:
	_have_loop_ended = cb


func start_report() -> void:
	_report = AuditReport.new()


@abstract func run() -> void

@abstract func get_report() -> AuditReport

@abstract func get_audit_header() -> String
