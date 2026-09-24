class_name HeroCardData
extends CardData

@export var stance_for_bonus: Hero.Stance
@export var stance_after_clash: Hero.Stance


func on_play(villain: Villain, hero: Hero):
	pass


func on_clash(villain: Villain, hero: Hero):
	if hero.is_in_stance(stance_for_bonus):
		for effect in bonus_effects:
			effect.on_clash(villain, hero)
	for effect in effects:
		effect.on_clash(villain, hero)


func after_clash(villain: Villain, hero: Hero):
	hero.change_stance(stance_after_clash)
	resolved.emit(self)
	
	
func on_discard(villain: Villain, hero: Hero):
	pass
