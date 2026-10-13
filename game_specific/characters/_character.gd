@abstract class_name Character
extends Resource

@export var character_name: String
@export var max_health: int
@export var health: int
@export var deck: Deck


func create_state_copy() -> Character:
	var copy := duplicate() as Character
	copy.character_name = character_name
	copy.max_health = max_health
	copy.health = health
	copy.deck = deck.create_state_copy() if deck != null else null
	return copy


func prepare() -> void:
	if deck != null:
		deck.prepare()


@abstract func draw() -> AuditOutcome


@abstract func take_damage(damage: int, ignores_armor: bool) -> AuditOutcome


@abstract func take_attack(attack: Attack) -> AuditOutcome


@abstract func heal(amount_to_heal: int) -> AuditOutcome


func restore_character_state_from(source: Character) -> void:
	character_name = source.character_name
	max_health = source.max_health
	health = source.health
	if source.deck == null:
		deck = null
	elif deck == null:
		deck = source.deck.create_state_copy()
	else:
		deck.restore_state_from(source.deck)
