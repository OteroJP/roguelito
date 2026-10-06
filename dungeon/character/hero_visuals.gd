class_name HeroVisuals
extends Area2D

signal played_card_anim_finished
signal stance_changed

@onready var name_label: Label = %Name
@onready var art: Sprite2D = %Art
@onready var armor_bar: ProgressBar = %ArmorBar
@onready var armor_label: Label = %ArmorLabel
@onready var armor_delta: Label = %DeltaArmor
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_label: Label = %HealthLabel
@onready var health_delta: Label = %DeltaHealth
@onready var damage_label: Label = %Damage
@onready var _Statuses: HBoxContainer = %Statuses

var _hero: Hero

func _ready() -> void:
	name_label.text = _hero.character_name
	health_bar.max_value = _hero.max_health
	health_bar.value = _hero.health
	health_label.text = "%d / %d" % [_hero.health, _hero.max_health]
	health_delta.text = ""
	armor_bar.max_value = _hero.max_armor
	armor_bar.value = _hero.armor
	armor_label.text = "%d / %d" % [_hero.armor, _hero.max_armor]
	armor_delta.text = ""
	change_stance(_hero.current_stance)
	_add_modifier_icons()
	

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
	var delta_armor_value = int(_hero.armor - armor_bar.value)
	if delta_armor_value != 0:
		armor_delta.text = _format_delta_text(delta_armor_value)
		var armor_delta_tween: Tween = await LabelAnimation.animate_label_num_delta(armor_delta)

	var delta_health_value = (_hero.health - health_bar.value)
	if delta_health_value != 0:
		health_delta.text = _format_delta_text(delta_health_value)
		var health_delta_tween: Tween = await LabelAnimation.animate_label_num_delta(health_delta)

	var armor_bar_tween: Tween = RangeAnimation.animate_range_decrease(
		armor_bar,
		absf(armor_bar.value - _hero.armor)
	)
	armor_label.text = "%d / %d" % [_hero.armor, _hero.max_armor]
	var health_bar_tween: Tween = RangeAnimation.animate_range_decrease(
		health_bar,
		absf(health_bar.value - _hero.health)
	)
	health_label.text = "%d / %d" % [_hero.health, _hero.max_health]
	damage_label.text = "%d / %d" % [_hero.basic_damage, _hero.max_basic_damage]
	#await animation_tween.finished
	#health_bar.value = _hero.health


func change_stance(new_stance: Hero.Stance) -> void:
	art.texture = UIAssets.STANCE_LIBRARY[new_stance]
	await get_tree().process_frame
	stance_changed.emit()


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
	
	
func _format_delta_text(delta: int) -> String:
	var delta_string: String
	if delta > 0:
		delta_string = "+%s" % str(delta)
	else:
		delta_string = str(delta)
	return delta_string


func add_status(status: Status) -> void:
	var new_status_icon: StatusIcon = StatusIcon.new_status_icon(status)
	_Statuses.add_child(new_status_icon)


func _add_modifier_icons() -> void:
	_Statuses.add_child(DamageModificationIcon.new_icon(_hero))
	_Statuses.add_child(BonusSpeedIcon.new_icon(_hero))
	_Statuses.add_child(IgnoreArmorIcon.new_icon(_hero))
