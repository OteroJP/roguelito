@abstract class_name CardData
extends Resource

@export var name: String
@export var art: Texture2D
@export var effect: Array[CardEffect]
@export var effect_bonus: Array[CardEffect]

#CardDataVillain
#extends CardData
#symbol_finish: Symbol
#symbol_start: Symbol
