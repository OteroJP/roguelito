class_name BonusSpeedIcon
extends StatIcon


static func new_icon(_character: Character) -> BonusSpeedIcon:
	var icon: BonusSpeedIcon = UIAssets.BONUS_SPEED_ICON_SCENE.instantiate() as BonusSpeedIcon
	icon.character = _character
	return icon


func refresh() -> void:
	var total := character.speed_bonus
	var text := ""
	if total > 0:
		text = "%s gains %d speed" % [character.character_name, total]
	elif total < 0:
		text = "%s loses %d speed" % [character.character_name, absi(total)]
	_apply_amount(total, text)
