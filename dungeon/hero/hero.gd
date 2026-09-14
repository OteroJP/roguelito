class_name Hero
extends Character

var hero_visuals: HeroVisuals

const HERO_SCENE: PackedScene = preload("res://dungeon/hero/hero.tscn")


func create_node() -> HeroVisuals:
	var _hero_visuals: HeroVisuals = HERO_SCENE.instantiate() as HeroVisuals
	hero_visuals = _hero_visuals
	return hero_visuals


func play_card() -> void:
	GameManager.current_hero_card = deck.draw()
	hero_visuals.play_card()
	await hero_visuals.played_card_anim_finished


func get_ready() -> void:
	#TODO Implement stance selection -> actually, it goes after card resolution
	pass
