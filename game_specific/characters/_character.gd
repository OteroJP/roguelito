@abstract class_name Character
extends Resource

@export var character_name: String
@export var max_health: int
@export var health: int
@export var deck: Deck
@export var immune_to_damage: bool = false


func create_state_copy() -> Character:
	var copy := duplicate() as Character
	copy.character_name = character_name
	copy.max_health = max_health
	copy.health = health
	copy.deck = deck.create_state_copy() if deck != null else null
	copy.immune_to_damage = immune_to_damage
	return copy


func prepare() -> void:
	if deck != null:
		deck.prepare()


@abstract func draw() -> void


@abstract func take_damage(damage: int, ignores_armor: bool) -> void


@abstract func take_attack(attack: Attack) -> void


@abstract func heal(amount_to_heal: int) -> void


func clear_immunity() -> void:
	immune_to_damage = false


func restore_character_state_from(source: Character) -> void:
	character_name = source.character_name
	max_health = source.max_health
	health = source.health
	immune_to_damage = source.immune_to_damage
	if source.deck == null:
		deck = null
	elif deck == null:
		deck = source.deck.create_state_copy()
	else:
		deck.restore_state_from(source.deck)
