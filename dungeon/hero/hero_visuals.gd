class_name HeroVisuals
extends Area2D

signal played_card_anim_finished

@onready var name_label: Label = %Name
@onready var art: Sprite2D = %Art
@onready var life_bar: ProgressBar = %LifeBar


func setup(hero: Hero):
	name_label.text = hero.character_name
	life_bar.max_value = hero.max_health
	life_bar.value = hero.health


func play_card():
	shake_sprite()
	played_card_anim_finished.emit()


func shake_sprite() -> void:
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
