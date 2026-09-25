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
	for modifier in attack_modifiers:
		modifier.spend_use()
	immune_to_damage = false
	GameManager.is_current_hero_card_enabled =  true


func take_damage(damage: int, ignores_armor: bool = false) -> void:
	var incoming_damage := damage
	if not ignores_armor:
		var absorbed_damage := mini(armor, incoming_damage)
		armor -= absorbed_damage
		incoming_damage -= absorbed_damage
	health -= incoming_damage
	character_stats_changed.emit()


func take_attack(attack: Attack) -> void:
	if immune_to_damage:
		return
	take_damage(attack.damage, attack.ignores_armor)
	

func perform_attack(target: Character, damage: int = 0, ignores_armor: bool = false) -> void:
	var new_attack: Attack = Attack.new(target, damage, ignores_armor)
	for modifier in attack_modifiers:
		modifier.modify_attack(new_attack)
	target.take_attack(new_attack)
	
	
func increase_max_armor(increase: int) -> void:
	max_armor += increase
	
	
func increase_max_health(increase: int) -> void:
	max_health += increase	
	
	
func increase_max_basic_damage(increase: int) -> void:
	max_basic_damage += increase
	
	
func heal(amount_to_heal: int) -> void:
	health += amount_to_heal
	character_stats_changed.emit()
