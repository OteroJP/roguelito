class_name CharacterDefeated extends EndCondition

var _character : Character


func _init(character: Character) -> void:
	_character = character


func was_satisfied() -> bool:
	if _character.health <= 0:
		satisfied.emit(self)
	return _character.health <= 0


func get_outcome() -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if _character is Hero:
		outcome.add(AuditEvent.Kind.HERO_DEFEATED, AuditLogEntry.Source.HERO)
	else:
		outcome.add(AuditEvent.Kind.PLAYER_LOST, AuditLogEntry.Source.GAME)
	return outcome
