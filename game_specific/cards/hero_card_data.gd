@tool
class_name HeroCardData
extends CardData

@export var stance_for_bonus: Hero.Stance
@export var stance_after_clash: Hero.Stance
@export var removable: bool = true


func _bonus_color() -> Color:
	return UIAssets.HERO_BONUS_STANCE_COLOR
