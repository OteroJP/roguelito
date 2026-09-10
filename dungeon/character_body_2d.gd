extends CharacterBody2D
@onready var c: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	var character_shape: CapsuleShape2D = c.shape
	var entrance_tween: Tween = create_tween()
	var final_radius: float = character_shape.radius
	var final_height: float = character_shape.height
	character_shape.radius = 0
	character_shape.height = 0
	entrance_tween.set_parallel()
	position -= Vector2(-5,20)
	entrance_tween.tween_property(
		self, "position", position + Vector2(-10,20), 2
		).set_trans(Tween.TRANS_CUBIC)
	entrance_tween.tween_property(character_shape, "radius", final_radius, 2)
	entrance_tween.tween_property(character_shape, "height", final_height, 2)
