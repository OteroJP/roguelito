class_name Hero
extends Character

enum Stance { NONE, ATTACK, DEFEND, UPGRADE }

@export var max_basic_damage: int
@export var basic_damage: int
@export var max_armor: int
@export var armor: int
@export var immune_to_damage: bool = false

var current_stance: Stance = Stance.NONE

func draw() -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if not deck.may_draw(1):
		deck.reshuffle()
	var card: CardData = deck.draw()
	return outcome


func play_card() -> HeroCardData:
	var card := deck.pick_random_card() as HeroCardData
	deck.play(card)
	return card


func change_stance(target_stance: Stance) -> void:
	current_stance = target_stance


func is_in_stance(stance_to_check: Stance) -> bool:
	return true if current_stance == stance_to_check else false


func create_state_copy() -> Hero:
	var copy := super.create_state_copy() as Hero
	copy.max_basic_damage = max_basic_damage
	copy.basic_damage = basic_damage
	copy.max_armor = max_armor
	copy.armor = armor
	copy.immune_to_damage = immune_to_damage
	copy.current_stance = current_stance
	return copy


func restore_hero_state_from(source: Hero) -> void:
	max_basic_damage = source.max_basic_damage
	basic_damage = source.basic_damage
	max_armor = source.max_armor
	armor = source.armor
	immune_to_damage = source.immune_to_damage
	current_stance = source.current_stance
	restore_character_state_from(source)


func clear_immunity() -> void:
	immune_to_damage = false


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
	return outcome


func set_health(new_health: int) -> void:
	health = new_health


func take_attack(attack: Attack) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if immune_to_damage:
		outcome.add(AuditEvent.Kind.IMMUNITY_RESISTED, AuditLogEntry.Source.HERO)
		return outcome
	return take_damage(attack.damage, attack.ignores_armor)


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
	outcome.add(AuditEvent.Kind.HEALED, AuditLogEntry.Source.HERO, amount_to_heal)
	return outcome


func set_armor(new_armor: int) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	armor = min(new_armor, max_armor)
	outcome.add(AuditEvent.Kind.ARMOR_CHANGED, AuditLogEntry.Source.HERO, new_armor)
	return outcome
