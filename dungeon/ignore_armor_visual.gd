class_name IgnoreArmorIcon
extends StatIcon


static func new_icon(_character: Character) -> IgnoreArmorIcon:
	var icon: IgnoreArmorIcon = UIAssets.IGNORE_ARMOR_ICON_SCENE.instantiate() as IgnoreArmorIcon
	icon.character = _character
	return icon


func refresh() -> void:
	var active := false
	for modifier in character.attack_modifiers:
		if modifier.ignores_armor:
			active = true
			break
	var text := ""
	if active:
		text = "%s's attacks ignore armor" % character.character_name
	_apply_active(active, text)
