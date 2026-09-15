@abstract class_name LoopPhase extends RefCounted

signal phase_ended

var _have_loop_ended: Callable

func add_end_condition(cb: Callable) -> void:
	_have_loop_ended = cb

@abstract func run() -> void
