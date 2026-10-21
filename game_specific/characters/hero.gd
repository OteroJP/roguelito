class_name Hero
extends Character

enum Stance { NONE, ATTACK, DEFEND, UPGRADE }

@export var max_basic_damage: int
@export var basic_damage: int
@export var max_armor: int
@export var armor: int

var current_stance: Stance = Stance.NONE

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
	copy.current_stance = current_stance
	return copy


func restore_hero_state_from(source: Hero) -> void:
	max_basic_damage = source.max_basic_damage
	basic_damage = source.basic_damage
	max_armor = source.max_armor
	armor = source.armor
	current_stance = source.current_stance
	restore_character_state_from(source)


func take_damage(damage: int, ignores_armor: bool = false) -> void:
	var incoming_damage := damage
	if not ignores_armor:
		var absorbed_damage := mini(armor, incoming_damage)
		armor -= absorbed_damage
		incoming_damage -= absorbed_damage
	health -= incoming_damage


func set_health(new_health: int) -> void:
	health = new_health


func increase_max_armor(increase: int) -> void:
	max_armor += increase


func increase_max_health(increase: int) -> void:
	max_health += increase


func increase_max_basic_damage(increase: int) -> void:
	max_basic_damage += increase


func set_armor(new_armor: int) -> void:
	armor = min(new_armor, max_armor)
