extends Control

@onready var _health_label: Label = %HealthLabel
@onready var _continue_button: Button = %ContinueButton


func _ready() -> void:
	_continue_button.pressed.connect(_on_continue_pressed)
	_refresh()


func _refresh() -> void:
	if not RunController.has_active_run():
		_health_label.text = "No hay una partida activa"
		_continue_button.disabled = true
		return
	var hero := RunController.current_options.hero
	_health_label.text = "%s: %d / %d" % [hero.character_name, hero.health, hero.max_health]


func _on_continue_pressed() -> void:
	RunController.start_next_combat()
