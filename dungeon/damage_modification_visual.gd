class_name DamageModificationIcon
extends StatIcon


static func new_icon(_character: Character) -> DamageModificationIcon:
	var icon: DamageModificationIcon = UIAssets.DAMAGE_MODIFICATION_ICON_SCENE.instantiate() as DamageModificationIcon
	icon.character = _character
	return icon


func refresh() -> void:
	var total := 0
	for modifier in character.attack_modifiers:
		total += modifier.damage_modification
	var text := ""
	if total > 0:
		text = "%s's attacks deal %d more damage" % [character.character_name, total]
	elif total < 0:
		text = "%s's attacks deal %d less damage" % [character.character_name, absi(total)]
	_apply_amount(total, text)
