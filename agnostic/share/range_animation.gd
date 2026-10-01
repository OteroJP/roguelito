# Animation constants (will be replaced by StyleResource later)
class_name RangeAnimation

const DEFAULT_DURATION : float = 1
const DEFAULT_EASE: Tween.EaseType = Tween.EASE_OUT
const DEFAULT_TRANSITION: Tween.TransitionType = Tween.TRANS_QUAD

# For decreasing values
static func animate_range_decrease(
	range_node: Range,
	amount: float,
	duration: float = RangeAnimation.DEFAULT_DURATION,
	ease: Tween.EaseType = RangeAnimation.DEFAULT_EASE,
	transition: Tween.TransitionType = RangeAnimation.DEFAULT_TRANSITION
) -> Tween:
	var target_value : float = max(range_node.min_value, range_node.value - amount)
	var tween : Tween = range_node.create_tween()
	(
	tween.tween_property(
		range_node,
		"value",
		target_value,
		duration
	)
	.set_ease(ease)
	.set_trans(transition)
	)
	# TODO: Callback functionality will be added later
	# if on_complete:
	#     tween.tween_interval(0.0).set_callback(on_complete.bind(range_node, target_value))
	return tween

# For increasing values
static func animate_range_increase(
	range_node: Range,
	amount: float,
	duration: float = RangeAnimation.DEFAULT_DURATION,
	ease: Tween.EaseType = RangeAnimation.DEFAULT_EASE,
	transition: Tween.TransitionType = RangeAnimation.DEFAULT_TRANSITION
) -> Tween:
	var target_value : float = min(range_node.max_value, range_node.value + amount)
	var tween: Tween = range_node.create_tween()
	(
	tween.tween_property(
		range_node,
		"value",
		target_value,
		duration
	)
	.set_ease(ease)
	.set_trans(transition)
	)
	# TODO: Callback functionality will be added later
	# if on_complete:
	#     tween.tween_interval(0.0).set_callback(on_complete.bind(range_node, target_value))
	return tween
