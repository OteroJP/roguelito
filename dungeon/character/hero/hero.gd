class_name Hero
extends Character

var _hero_visuals: HeroVisuals

const HERO_SCENE: PackedScene = preload("uid://dsakfrfgkdj8u")


func prepare() -> HeroVisuals:
	deck.prepare()
	var hero_visuals: HeroVisuals = HERO_SCENE.instantiate() as HeroVisuals
	_hero_visuals = hero_visuals.setup(self)
	return _hero_visuals


func draw() -> void:
	if not deck.may_draw(1):
		deck.reshuffle()
	var card: CardData = deck.draw()
	await _hero_visuals.change_stance(card)


func play_card() -> void:
	var only_card_in_hand = deck.pick_random_card()
	deck.play(only_card_in_hand)
	GameManager.current_hero_card = only_card_in_hand
	_hero_visuals.play_card()
	#await _hero_visuals.get_tree().process_frame 
	await _hero_visuals.played_card_anim_finished
	pass


#TODO? Implement stance selection -> actually, it goes after card resolution
#func get_ready() -> void:
#	await get_tree().process_frame 
#	pass
