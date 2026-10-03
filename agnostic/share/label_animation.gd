# Animation constants (will be replaced by StyleResource later)
class_name LabelAnimation

const DEFAULT_DURATION : float = 1
const DEFAULT_Y_OFFSET: float = -20
const DEFAULT_EASE: Tween.EaseType = Tween.EASE_OUT
const DEFAULT_TRANSITION: Tween.TransitionType = Tween.TRANS_QUAD

# For decreasing values
static func animate_label_num_delta(
	label_node: Label,
	duration: float = RangeAnimation.DEFAULT_DURATION,
	ease: Tween.EaseType = RangeAnimation.DEFAULT_EASE,
	transition: Tween.TransitionType = RangeAnimation.DEFAULT_TRANSITION
) -> Tween:
	label_node.offset_transform_enabled = true
	var tween: Tween = label_node.create_tween()
	tween.set_ease(ease)
	tween.set_trans(transition)
	tween.tween_property(
		label_node,
		"offset_transform_position",
		Vector2(0, DEFAULT_Y_OFFSET),
		duration
	)
	tween.parallel().tween_property(
		label_node,
		"modulate:a",
		0,
		duration
	)
	await tween.finished
	label_node.text = ""
	label_node.modulate.a = 1
	label_node.offset_transform_position = Vector2.ZERO
	return tween
