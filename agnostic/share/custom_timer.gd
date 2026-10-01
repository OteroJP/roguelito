## Lightweight Class design to be used by a [Node] to use as a timer without needing to create [Timer].
class_name CustomTimer extends RefCounted

## [Signal] emited by a [CustomTimer] when every [member CustomTimer._duration] seconds
signal timeout

## State of the current []
enum State {
	IDLE,
	RUNNING,
	PAUSED
}

var _duration: float = 0.0
var _remaining_timeouts: int = 0

var _callback: Callable
var _time_left: float = 0.0
var _state: State = State.IDLE
var _early_end_callback: Callable


func _init(duration: float, callback: Callable, max_timeouts: int) -> void:
	_duration = duration
	_callback = callback
	_remaining_timeouts = max_timeouts
	_time_left = duration
	_state = State.IDLE


## Starts the timer
func start() -> void:
	if _state != State.IDLE:
		return
	_state = State.RUNNING


## Updates the timer (call this in _process if used in a Node)
func update(delta: float) -> void:
	if _state == State.RUNNING:
		_time_left -= delta
		if _time_left <= 0:
			_time_left += _duration
			_remaining_timeouts -= 1
			timeout.emit()
			_callback.call(_remaining_timeouts)
		if _remaining_timeouts <= 0:
			_state = State.IDLE


func pause() -> void:
	_state = State.PAUSED if _state == State.RUNNING else _state


func resume() -> void:
	_state = State.RUNNING if _state == State.PAUSED else _state


func end_early() -> void:
	var _was_idle: bool = _state == State.IDLE
	_state = State.IDLE
	if not _was_idle and _early_end_callback:
		_early_end_callback.call()


func add_early_end_callback(cb: Callable) -> void:
	_early_end_callback = cb
