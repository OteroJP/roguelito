class_name VillainSpeeds
extends CardEffect
## Increases should always be multiple of 2 so there are no ties

@export var speed_modification: int

func on_clash(villain: Villain, hero: Hero):
	villain.get_bonus_speed(speed_modification)
