class_name Hero
extends Character

signal stance_changed(new_stance: Stance)

enum Stance { NONE, ATTACK, DEFEND, UPGRADE }

@export var max_armor: int
@export var armor: int

var current_stance: Stance = Stance.NONE
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
