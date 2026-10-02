class_name VillainSpell
extends Resource

@export var name: String
@export var mana_cost: int = 1
@export var btn_asset: Texture2D
@export var btn_asset_disabled: Texture2D
@export var effects: Array[Effect]
@export_multiline() var tooltip: String
