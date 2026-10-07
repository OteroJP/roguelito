class_name SpellButton
extends TextureButton

@onready var label: Label = %Count
@onready var symbol_texture: TextureRect = %Symbol
@onready var bonus_texture: TextureRect = %Bonus

var _data: VillainSpell
var _villain: Villain
var _used_this_turn: bool = false
var _outside_spell_window: bool = true


func _ready() -> void:
	texture_normal = _data.btn_asset
	texture_disabled = _data.btn_asset_disabled
	_villain.character_stats_changed.connect(_refresh_enabled)
	_refresh_enabled()


func _refresh_enabled() -> void:
	disabled = (
		_used_this_turn
		or _data.mana_cost > _villain.mana
		or _outside_spell_window
	)


func get_effects() -> Array[Effect]:
	return _data.effects


func _pressed() -> void:
	_used_this_turn = true
	pressed.emit(_data)
	_villain.audit_report.add("Used %s spell." % _data.name, AuditLogEntry.Source.VILLAIN)
	_refresh_enabled()
	

func enable_spell_cast(enabled: bool) -> void:
	_outside_spell_window = not enabled
	reset_use()
	_refresh_enabled()


func reset_use() -> void:
	_used_this_turn = false


static func new_spell_button(data: VillainSpell, villain: Villain) -> SpellButton:
	var button: SpellButton = UIAssets.SPELL_BUTTON_SCENE.instantiate() as SpellButton
	button._data = data
	button._villain = villain
	button.name = "%s Spell" % str(button._data.name)
	return button
	
