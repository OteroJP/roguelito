class_name BonusSpeedIcon
extends StatIcon

var _character_name: String
var _speed_bonus: int = 0


static func new_icon(character_name: String) -> BonusSpeedIcon:
	var icon: BonusSpeedIcon = UIAssets.BONUS_SPEED_ICON_SCENE.instantiate() as BonusSpeedIcon
	icon._character_name = character_name
	return icon


func set_speed_bonus(speed_bonus: int) -> void:
	_speed_bonus = speed_bonus
	refresh()


func refresh() -> void:
	var total := _speed_bonus
	var text := ""
	if total > 0:
		text = "%s gains %d speed" % [_character_name, total]
	elif total < 0:
		text = "%s loses %d speed" % [_character_name, absi(total)]
	_apply_amount(total, text)
