class_name CombatManager extends RefCounted


class CombatantState:
	extends RefCounted

	var statuses: Array[Status] = []
	var attack_modifiers: Array[AttackModifier] = []
	var speed_bonus: int = 0


# Keep each combatant's port instance stable for this combat; state is keyed by port identity.
var _combatant_states: Dictionary[CharacterPort, CombatantState] = {}
var _hero_port: HeroPort
var _villain_port: VillainPort


func _init(hero_port: HeroPort, villain_port: VillainPort) -> void:
	_hero_port = hero_port
	_villain_port = villain_port
	_combatant_states[hero_port] = CombatantState.new()
	_combatant_states[villain_port] = CombatantState.new()


func run_effect_batch(
	effects: Array[Effect],
	villain_port: VillainPort,
	hero_port: HeroPort
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	for effect: Effect in effects:
		outcome.append(await effect.on_clash(villain_port, hero_port, self))
	return outcome


func add_status(combatant_port: CharacterPort, status: Status) -> Status:
	var applied_status := status.duplicate(true) as Status
	_get_state(combatant_port).statuses.append(applied_status)
	# TODO reset: reconnect this signal for every Status restored from saved turn state.
	applied_status.status_depleted.connect(_on_status_depleted.bind(combatant_port))
	return applied_status


func statuses_for(combatant_port: CharacterPort) -> Array[Status]:
	return _get_state(combatant_port).statuses.duplicate()


func remove_status(combatant_port: CharacterPort, status: Status) -> void:
	_get_state(combatant_port).statuses.erase(status)


func tick_statuses(combatant_port: CharacterPort) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var active_statuses := statuses_for(combatant_port)
	for status: Status in active_statuses:
		if not _get_state(combatant_port).statuses.has(status):
			continue
		outcome.add(
			AuditEvent.Kind.STATUS_TICKED,
			_source_for(combatant_port),
			0,
			status.name
		)
		outcome.append(await run_effect_batch(status.status_effects, _villain_port, _hero_port))
		status.advance_duration()
	return outcome


func _on_status_depleted(status: Status, combatant_port: CharacterPort) -> void:
	remove_status(combatant_port, status)


func add_attack_modifier(combatant_port: CharacterPort, modifier: AttackModifier) -> void:
	var modifiers := _get_state(combatant_port).attack_modifiers
	modifiers.append(modifier)
	var depleted_callback := _on_attack_modifier_depleted.bind(combatant_port)
	if not modifier.attack_modifier_depleted.is_connected(depleted_callback):
		modifier.attack_modifier_depleted.connect(depleted_callback)


func attack_modifiers_for(combatant_port: CharacterPort) -> Array[AttackModifier]:
	return _get_state(combatant_port).attack_modifiers.duplicate()


func remove_attack_modifier(combatant_port: CharacterPort, modifier: AttackModifier) -> void:
	_get_state(combatant_port).attack_modifiers.erase(modifier)
	var depleted_callback := _on_attack_modifier_depleted.bind(combatant_port)
	if modifier.attack_modifier_depleted.is_connected(depleted_callback):
		modifier.attack_modifier_depleted.disconnect(depleted_callback)


func _on_attack_modifier_depleted(
	modifier: AttackModifier,
	combatant_port: CharacterPort
) -> void:
	remove_attack_modifier(combatant_port, modifier)


func add_speed_bonus(combatant_port: CharacterPort, amount: int) -> void:
	_get_state(combatant_port).speed_bonus += amount


func speed_bonus_for(combatant_port: CharacterPort) -> int:
	return _get_state(combatant_port).speed_bonus


func clear_speed_bonus(combatant_port: CharacterPort) -> void:
	_get_state(combatant_port).speed_bonus = 0


func clear_round_modifiers() -> void:
	_clear_round_modifiers_for(_hero_port)
	_clear_round_modifiers_for(_villain_port)


func _clear_round_modifiers_for(combatant_port: CharacterPort) -> void:
	var state := _get_state(combatant_port)
	clear_speed_bonus(combatant_port)
	for modifier: AttackModifier in state.attack_modifiers.duplicate():
		modifier.spend_use()



func perform_attack(
	attacker_port: CharacterPort,
	attacker: Character,
	target: Character,
	damage: int,
	ignores_armor: bool = false
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var attack := Attack.new(target, damage, ignores_armor)
	for modifier: AttackModifier in attack_modifiers_for(attacker_port):
		modifier.modify_attack(attack)
	outcome.add(
		AuditEvent.Kind.ATTACK,
		_source_for(attacker_port),
		damage,
		"",
		target.character_name,
		ignores_armor
	)
	outcome.append(target.take_attack(attack))
	return outcome


func _get_state(combatant_port: CharacterPort) -> CombatantState:
	assert(
		_combatant_states.has(combatant_port),
		"Combatant port was not registered at initialization."
	)
	return _combatant_states[combatant_port] as CombatantState


func _source_for(character_port: CharacterPort) -> AuditLogEntry.Source:
	if character_port is HeroPort:
		return AuditLogEntry.Source.HERO
	if character_port is VillainPort:
		return AuditLogEntry.Source.VILLAIN
	assert(false, "Unknown combatant port.")
	return AuditLogEntry.Source.GAME
