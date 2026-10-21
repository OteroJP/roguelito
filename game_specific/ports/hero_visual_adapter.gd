class_name HeroVisualAdapter
extends HeroPort

const HERO_SCENE: PackedScene = preload("uid://dsakfrfgkdj8u")

var _hero: Hero
var _hero_visuals: HeroVisuals


func _init(hero: Hero, visual_parent: Node) -> void:
	_hero = hero
	_hero.prepare()
	_hero_visuals = HERO_SCENE.instantiate() as HeroVisuals
	_hero_visuals.setup(_hero)
	visual_parent.add_child(_hero_visuals)


func get_character() -> Hero:
	return _hero.create_state_copy()


func prepare_for_combat() -> void:
	# HeroVisuals initializes its presentation when it enters the scene tree.
	pass


func update_character(character: Character) -> void:
	assert(character is Hero, "HeroVisualAdapter can only update from Hero state.")
	var hero_state := character as Hero
	_hero.restore_hero_state_from(hero_state)
	await _synchronize_presentation()


func discard_played_card(card: CardData) -> void:
	_hero.deck.discard_played_card(card)


func change_stance(target_stance: Hero.Stance) -> void:
	_hero.change_stance(target_stance)
	await _hero_visuals.change_stance(target_stance)


func clear_immunity() -> void:
	_hero.clear_immunity()


func draw() -> void:
	_hero.draw()


func play_card() -> HeroCardData:
	var card: HeroCardData = _hero.play_card()
	await _synchronize_presentation()
	_hero_visuals.play_card()
	await _hero_visuals.played_card_anim_finished
	return card


func sync_combat_indicators(
	statuses: Array[Status],
	_attack_modifiers: Array[AttackModifier],
	_speed_bonus: int
) -> void:
	# TODO: Add Hero modifier and speed indicators in a future macrostep.
	_hero_visuals.restore_statuses(statuses)


func _synchronize_presentation() -> void:
	await _hero_visuals.update()
	await _hero_visuals.change_stance(_hero.current_stance)
