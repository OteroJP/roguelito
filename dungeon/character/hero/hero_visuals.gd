class_name HeroVisuals
extends Area2D

signal played_card_anim_finished

@onready var name_label: Label = %Name
@onready var art: Sprite2D = %Art
@onready var life_bar: ProgressBar = %LifeBar

var _hero: Hero


func _ready() -> void:
	name_label.text = _hero.character_name
	life_bar.max_value = _hero.max_health
	life_bar.value = _hero.health
	

func setup(hero: Hero) -> HeroVisuals:
	_hero = hero
	_hero.character_stats_changed.connect(update)
	return self


func play_card():
	_shake_sprite()
	await get_tree().create_timer(GameManager.ux_delay).timeout 
	played_card_anim_finished.emit()


func update() -> void:
	_shake_sprite()
	#TODO: pensar que pasa si se reciben muchos dannos muy rapido
	var animation_tween: Tween = RangeAnimation.animate_range_decrease(
		life_bar,
		absf(life_bar.value - _hero.health)
	)
	#await animation_tween.finished
	#life_bar.value = _hero.health


func change_stance(card: CardData) -> void:
	#TODO esto hay que reverlo
	await get_tree().process_frame 


func _shake_sprite() -> void:
	var original_position: Vector2 = art.position
	var tween: Tween = create_tween().set_parallel(false)
	var step_duration: float = 0.4 / 12
	for i in 10:
		var random_offset: Vector2 = Vector2(
			randf_range(-8.0, 8.0),
			randf_range(-8.0, 8.0)
		)
		tween.tween_property(art, "position", original_position + random_offset, step_duration)
	tween.tween_property(art, "position", original_position, step_duration)
	await tween.finished
