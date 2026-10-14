class_name HeroVisualAdapter
extends HeroPort

const HERO_SCENE: PackedScene = preload("uid://dsakfrfgkdj8u")

var _hero: Hero
var _hero_visuals: HeroVisuals
var _playing_area: PlayingArea


func _init(hero: Hero, visual_parent: Node, playing_area: PlayingArea) -> void:
	_hero = hero
	_playing_area = playing_area
	_hero.prepare()
	_hero_visuals = HERO_SCENE.instantiate() as HeroVisuals
	_hero_visuals.setup(_hero)
	visual_parent.add_child(_hero_visuals)


func get_character() -> Hero:
	return _hero.create_state_copy()


func prepare_for_combat() -> void:
	# HeroVisuals initializes its presentation when it enters the scene tree.
	pass


func update_character(character: Hero) -> void:
	_hero.restore_hero_state_from(character)
	await _synchronize_presentation()


func change_stance(target_stance: Hero.Stance) -> void:
	_hero.change_stance(target_stance)
	await _hero_visuals.change_stance(target_stance)


func draw() -> AuditOutcome:
	return await _hero.draw()


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


func reveal_played_card() -> void:
	_playing_area.enable_hero_card_visibility(true)


func _synchronize_presentation() -> void:
	await _hero_visuals.update()
	await _hero_visuals.change_stance(_hero.current_stance)
