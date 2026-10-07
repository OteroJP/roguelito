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
var audit_report: AuditReport

const HERO_SCENE: PackedScene = preload("uid://dsakfrfgkdj8u")


func prepare() -> HeroVisuals:
	deck.prepare()
	var hero_visuals: HeroVisuals = HERO_SCENE.instantiate() as HeroVisuals
	_hero_visuals = hero_visuals.setup(self)
	statuses.clear()
	return _hero_visuals


func draw() -> void:
	if not deck.may_draw(1):
		deck.reshuffle()
	var card: CardData = deck.draw()


func play_card() -> void:
	var only_card_in_hand = deck.pick_random_card()
	deck.play(only_card_in_hand)
	GameManager.play_hero_card(only_card_in_hand)
	_hero_visuals.play_card()
	#await _hero_visuals.get_tree().process_frame 
	await _hero_visuals.played_card_anim_finished


func change_stance(target_stance: Stance) -> void:
	current_stance = target_stance
	_hero_visuals.change_stance(target_stance)
	await _hero_visuals.stance_changed
	
	
func is_in_stance(stance_to_check: Stance) -> bool:
	return true if current_stance == stance_to_check else false


func end_phase() -> void:
	speed_bonus = 0
	for modifier in attack_modifiers.duplicate():
		modifier.spend_use()
	immune_to_damage = false
	GameManager.is_current_hero_card_enabled =  true
	modifiers_changed.emit()


func take_damage(damage: int, ignores_armor: bool = false) -> void:
	var incoming_damage := damage
	if not ignores_armor:
		var absorbed_damage := mini(armor, incoming_damage)
		audit_report.add("Armor absorbed %s damage" % [str(absorbed_damage)], AuditLogEntry.Source.HERO)
		armor -= absorbed_damage
		incoming_damage -= absorbed_damage
	health -= incoming_damage
	audit_report.add("Suffered %s damage" % [str(incoming_damage)], AuditLogEntry.Source.HERO)
	character_stats_changed.emit()


func set_health(new_health: int) -> void:
	health = new_health
	character_stats_changed.emit()


func take_attack(attack: Attack) -> void:
	if immune_to_damage:
		audit_report.add("Hero resists damage due to immunity", AuditLogEntry.Source.HERO)
		return
	take_damage(attack.damage, attack.ignores_armor)


func perform_attack(target: Character, damage: int = 0, ignores_armor: bool = false) -> void:
	var new_attack: Attack = Attack.new(target, damage, ignores_armor)
	for modifier in attack_modifiers:
		modifier.modify_attack(new_attack)
	audit_report.add("Attacks %s for %s with pierce %s" % [target.character_name, str(damage), str(ignores_armor)], AuditLogEntry.Source.HERO)
	target.take_attack(new_attack)

	
func increase_max_armor(increase: int) -> void:
	max_armor += increase
	audit_report.add("Increases max armor by %s" % str(increase), AuditLogEntry.Source.HERO)
	
	
func increase_max_health(increase: int) -> void:
	max_health += increase	
	audit_report.add("Increases max health by %s" % str(increase), AuditLogEntry.Source.HERO)
	
func increase_max_basic_damage(increase: int) -> void:
	max_basic_damage += increase
	audit_report.add("Increases max basic damage by %s" % str(increase), AuditLogEntry.Source.HERO)

	
func heal(amount_to_heal: int) -> void:
	health = min((health + amount_to_heal), max_health)
	character_stats_changed.emit()
	audit_report.add("Heals for %s" % [str(amount_to_heal)], AuditLogEntry.Source.HERO)


func get_bonus_speed(_bonus_speed: int) -> void:
	speed_bonus += _bonus_speed
	modifiers_changed.emit()
	audit_report.add("Gets %s bonus speed" % [str(_bonus_speed)], AuditLogEntry.Source.HERO)


func set_armor(new_armor) -> void:
	armor = min(new_armor, max_armor)
	character_stats_changed.emit()
	audit_report.add("Changed armor to %s" % str(new_armor), AuditLogEntry.Source.HERO)


func take_status(status: Status) -> void:
	var new_status: Status = status.duplicate(true)
	statuses.append(new_status)
	new_status.status_depleted.connect(remove_status)
	await _hero_visuals.add_status(new_status)
	audit_report.add("Took a %s status" % new_status.name, AuditLogEntry.Source.HERO)

func tick_statuses(villain: Villain, hero: Hero) -> void:
	if statuses.is_empty():
		return
	for status in statuses:
		audit_report.add("Ticked %s status" % status.name, AuditLogEntry.Source.HERO)
		await status.on_tick(villain, hero)


func take_attack_modifier(modifier: AttackModifier) -> void:
	attack_modifiers.append(modifier)
	modifier.attack_modifier_depleted.connect(remove_attack_modifier)
	modifiers_changed.emit()
	audit_report.add("Got a combat modifier", AuditLogEntry.Source.HERO)
	
	
func remove_attack_modifier(modifier: AttackModifier) -> void:
	attack_modifiers.erase(modifier)
	modifiers_changed.emit()
	#Entiendo que siendo q son ref counted no necesitan free
