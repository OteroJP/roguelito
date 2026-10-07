class_name CombatInput
extends RefCounted

signal command_available

enum Command { CONFIRM, RESET }

var reset_requested: bool = false
var _commands: Array[int] = []


func submit_action(command: int) -> void:
	_commands.append(command)
	command_available.emit()


func request_reset() -> void:
	reset_requested = true
	submit_action(Command.RESET)


func wait_for_command() -> int:
	while _commands.is_empty():
		await command_available
	return _commands.pop_front()


func clear() -> void:
	_commands.clear()
	reset_requested = false
