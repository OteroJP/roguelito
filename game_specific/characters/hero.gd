class_name Hero
extends Character

signal stance_changed(new_stance: Stance)

enum Stance { NONE, ATTACK, DEFEND, UPGRADE }

@export var max_basic_damage: int
@export var basic_damage: int
@export var max_armor: int
@export var armor: int
@export var immune_to_damage: bool = false

var current_stance: Stance = Stance.NONE
var _hero_visuals: HeroVisuals

const HERO_SCENE: PackedScene = preload("uid://dsakfrfgkdj8u")


func prepare() -> HeroVisuals:
	deck.prepare()
	var hero_visuals: HeroVisuals = HERO_SCENE.instantiate() as HeroVisuals
	_hero_visuals = hero_visuals.setup(self)
	statuses.clear()
	return _hero_visuals


func draw() -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if not deck.may_draw(1):
		deck.reshuffle()
	var card: CardData = deck.draw()
	return outcome


func play_card() -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var only_card_in_hand = deck.pick_random_card()
	deck.play(only_card_in_hand)
	outcome.append(await GameManager.play_hero_card(only_card_in_hand))
	_hero_visuals.play_card()
	#await _hero_visuals.get_tree().process_frame
	await _hero_visuals.played_card_anim_finished
	return outcome


func change_stance(target_stance: Stance) -> void:
	current_stance = target_stance
	_hero_visuals.change_stance(target_stance)
	await _hero_visuals.stance_changed


func is_in_stance(stance_to_check: Stance) -> bool:
	return true if current_stance == stance_to_check else false


func end_phase() -> AuditOutcome:
	var outcome := AuditOutcome.new()
	speed_bonus = 0
	for modifier in attack_modifiers.duplicate():
		modifier.spend_use()
	immune_to_damage = false
	GameManager.is_current_hero_card_enabled =  true
	modifiers_changed.emit()
	return outcome


func take_damage(damage: int, ignores_armor: bool = false) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var incoming_damage := damage
	if not ignores_armor:
		var absorbed_damage := mini(armor, incoming_damage)
		outcome.add(AuditEvent.Kind.DAMAGE_ABSORBED, AuditLogEntry.Source.HERO, absorbed_damage)
		armor -= absorbed_damage
		incoming_damage -= absorbed_damage
	health -= incoming_damage
	outcome.add(AuditEvent.Kind.DAMAGE_SUFFERED, AuditLogEntry.Source.HERO, incoming_damage)
	character_stats_changed.emit()
	return outcome


func set_health(new_health: int) -> void:
	health = new_health
	character_stats_changed.emit()


func take_attack(attack: Attack) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if immune_to_damage:
		outcome.add(AuditEvent.Kind.IMMUNITY_RESISTED, AuditLogEntry.Source.HERO)
		return outcome
	return take_damage(attack.damage, attack.ignores_armor)


func perform_attack(target: Character, damage: int = 0, ignores_armor: bool = false) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var new_attack: Attack = Attack.new(target, damage, ignores_armor)
	for modifier in attack_modifiers:
		modifier.modify_attack(new_attack)
	outcome.add(AuditEvent.Kind.ATTACK, AuditLogEntry.Source.HERO, damage, "", target.character_name, ignores_armor)
	outcome.append(target.take_attack(new_attack))
	return outcome


func increase_max_armor(increase: int) -> AuditOutcome:
	max_armor += increase
	var outcome := AuditOutcome.new()
	outcome.add(AuditEvent.Kind.MAX_ARMOR_INCREASED, AuditLogEntry.Source.HERO, increase)
	return outcome


func increase_max_health(increase: int) -> AuditOutcome:
	max_health += increase
	var outcome := AuditOutcome.new()
	outcome.add(AuditEvent.Kind.MAX_HEALTH_INCREASED, AuditLogEntry.Source.HERO, increase)
	return outcome


func increase_max_basic_damage(increase: int) -> AuditOutcome:
	max_basic_damage += increase
	var outcome := AuditOutcome.new()
	outcome.add(AuditEvent.Kind.MAX_DAMAGE_INCREASED, AuditLogEntry.Source.HERO, increase)
	return outcome


func heal(amount_to_heal: int) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	health = min((health + amount_to_heal), max_health)
	character_stats_changed.emit()
	outcome.add(AuditEvent.Kind.HEALED, AuditLogEntry.Source.HERO, amount_to_heal)
	return outcome


func get_bonus_speed(_bonus_speed: int) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	speed_bonus += _bonus_speed
	modifiers_changed.emit()
	outcome.add(AuditEvent.Kind.BONUS_SPEED_CHANGED, AuditLogEntry.Source.HERO, _bonus_speed)
	return outcome


func set_armor(new_armor: int) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	armor = min(new_armor, max_armor)
	character_stats_changed.emit()
	outcome.add(AuditEvent.Kind.ARMOR_CHANGED, AuditLogEntry.Source.HERO, new_armor)
	return outcome


func take_status(status: Status) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var new_status: Status = status.duplicate(true)
	statuses.append(new_status)
	new_status.status_depleted.connect(remove_status)
	await _hero_visuals.add_status(new_status)
	outcome.add(AuditEvent.Kind.STATUS_TAKEN, AuditLogEntry.Source.HERO, 0, new_status.name)
	return outcome


func tick_statuses(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if statuses.is_empty():
		return outcome
	for status in statuses:
		outcome.add(AuditEvent.Kind.STATUS_TICKED, AuditLogEntry.Source.HERO, 0, status.name)
		outcome.append(await status.on_tick(villain, hero))
	return outcome


func take_attack_modifier(modifier: AttackModifier) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	attack_modifiers.append(modifier)
	modifier.attack_modifier_depleted.connect(remove_attack_modifier)
	modifiers_changed.emit()
	outcome.add(AuditEvent.Kind.COMBAT_MODIFIER_TAKEN, AuditLogEntry.Source.HERO)
	return outcome


func remove_attack_modifier(modifier: AttackModifier) -> void:
	attack_modifiers.erase(modifier)
	modifiers_changed.emit()
	#Entiendo que siendo q son ref counted no necesitan free
