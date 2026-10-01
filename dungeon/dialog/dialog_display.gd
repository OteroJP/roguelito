class_name DialogDisplay extends PanelContainer

signal dialog_continuation_requested
enum State {IDLE, WAITING, TYPING}


@export var time_between_letters = 0.03

var lines: Array[String] = [
	"You... again?",
	"I will come back as many times as it takes to vanquish you",
	"I hope that, this time, you can at least entertain me.",
	"LOREM IPSUM!"
	]
var _current_line_char: int = 0
var _current_line_ix: int = 0
var _current_state: State = State.IDLE

@onready var _TextLabel: RichTextLabel =  %Label
#@onready var margins = $TextMargins


func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if (
		event is InputEventKey
		and event.is_pressed()
		and not event.is_echo()
		and event.keycode == Key.KEY_SPACE
	):
		if _current_state == State.TYPING:
			_TextLabel.visible_ratio = 1
			_current_state = State.WAITING
		elif _current_state == State.WAITING:
			dialog_continuation_requested.emit()


func show_dialog() -> void:
	if _current_state != State.IDLE:
		return
	_current_line_ix = 0
	while _current_line_ix < lines.size():
		_current_state = State.TYPING
		await display_text(lines[_current_line_ix])
		_current_state = State.WAITING
		await dialog_continuation_requested
		_current_line_ix += 1
	_current_state = State.IDLE # TODO close


func display_text(text: String) -> void:
	_current_line_char = 0
	_TextLabel.visible_ratio = 0
	_TextLabel.text = text
	while _current_state == State.TYPING and _current_line_char < text.length():
		_current_line_char += 1
		_TextLabel.visible_ratio = maxf(
			_TextLabel.visible_ratio, 
			float(_current_line_char)/text.length()
			)
		await get_tree().create_timer(time_between_letters, false).timeout


func loop() -> DialogPhase:
	return DialogPhase.new(self)


class DialogPhase extends LoopPhase:
	
	var _display_node: DialogDisplay
	
	func _init(display_node: DialogDisplay) -> void:
		_display_node = display_node
		
	func run() -> void:
		_display_node.show()
		await _display_node.get_tree().create_timer(GameManager.ux_delay).timeout
		await _display_node.show_dialog()
		_display_node.hide()
