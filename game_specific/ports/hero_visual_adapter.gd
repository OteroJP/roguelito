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


func update_character(character: Hero) -> void:
	_hero.restore_hero_state_from(character)
	await _synchronize_presentation()


func change_stance(target_stance: Hero.Stance) -> void:
	_hero.change_stance(target_stance)
	await _hero_visuals.change_stance(target_stance)


func draw() -> AuditOutcome:
	return await _hero.draw()


func play_card() -> AuditOutcome:
	var outcome: AuditOutcome = await _hero.play_card()
	await _synchronize_presentation()
	_hero_visuals.play_card()
	await _hero_visuals.played_card_anim_finished
	return outcome


func _synchronize_presentation() -> void:
	await _hero_visuals.update()
	await _hero_visuals.change_stance(_hero.current_stance)
