class_name DamageModificationIcon
extends StatIcon

var _character_name: String
var _modifiers: Array[AttackModifier] = []


static func new_icon(character_name: String) -> DamageModificationIcon:
	var icon: DamageModificationIcon = UIAssets.DAMAGE_MODIFICATION_ICON_SCENE.instantiate() as DamageModificationIcon
	icon._character_name = character_name
	return icon


func set_modifiers(modifiers: Array[AttackModifier]) -> void:
	_modifiers = modifiers.duplicate()
	refresh()


func refresh() -> void:
	var total := 0
	for modifier: AttackModifier in _modifiers:
		total += modifier.damage_modification
	var text := ""
	if total > 0:
		text = "%s's attacks deal %d more damage" % [_character_name, total]
	elif total < 0:
		text = "%s's attacks deal %d less damage" % [_character_name, absi(total)]
	_apply_amount(total, text)
