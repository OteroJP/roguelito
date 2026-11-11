@tool
class_name HeroCardData
extends CardData

@export var stance_for_bonus: Hero.Stance
@export var stance_after_clash: Hero.Stance
@export var removable: bool = true


func bonus_condition_met(character: Character) -> bool:
	assert(character is Hero, "HeroCardData requires a Hero character.")
	return (character as Hero).is_in_stance(stance_for_bonus)


func _bonus_color() -> Color:
	return UIAssets.HERO_BONUS_STANCE_COLOR
