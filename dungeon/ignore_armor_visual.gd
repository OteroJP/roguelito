class_name IgnoreArmorIcon
extends StatIcon

var _character_name: String
var _modifiers: Array[AttackModifier] = []


static func new_icon(character_name: String) -> IgnoreArmorIcon:
	var icon: IgnoreArmorIcon = UIAssets.IGNORE_ARMOR_ICON_SCENE.instantiate() as IgnoreArmorIcon
	icon._character_name = character_name
	return icon


func set_modifiers(modifiers: Array[AttackModifier]) -> void:
	_modifiers = modifiers.duplicate()
	refresh()


func refresh() -> void:
	var active := false
	for modifier: AttackModifier in _modifiers:
		if modifier.ignores_armor:
			active = true
			break
	var text := ""
	if active:
		text = "%s's attacks ignore armor" % _character_name
	_apply_active(active, text)
