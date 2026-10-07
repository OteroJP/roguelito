@abstract class_name LoopPhase extends RefCounted

#signal phase_ended

var _have_loop_ended: Callable
var _report: AuditReport = AuditReport.new()

func add_end_condition(cb: Callable) -> void:
	_have_loop_ended = cb


func set_report(report: AuditReport) -> void:
	_report = report


@abstract func run() -> void

@abstract func get_report() -> AuditReport
