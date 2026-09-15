class_name Hero
extends Character

var _hero_visuals: HeroVisuals

const HERO_SCENE: PackedScene = preload("uid://dsakfrfgkdj8u")


func create_node() -> HeroVisuals:
	var hero_visuals: HeroVisuals = HERO_SCENE.instantiate() as HeroVisuals
	_hero_visuals = hero_visuals.setup(self)
	character_stats_changed.connect(_hero_visuals.update)
	return _hero_visuals


func play_card() -> void:
	if not deck.may_draw(1):
		deck.reshuffle()
	var card: CardData = deck.draw()
	deck.play(card)
	GameManager.current_hero_card = card
	_hero_visuals.play_card()
	#await _hero_visuals.get_tree().process_frame 
	await _hero_visuals.played_card_anim_finished


#TODO? Implement stance selection -> actually, it goes after card resolution
#func get_ready() -> void:
#	await get_tree().process_frame 
#	pass
