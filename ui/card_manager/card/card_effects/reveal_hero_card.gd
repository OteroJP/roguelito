class_name RevealHero
extends CardEffect

func on_clash(villain: Villain, hero: Hero):
	GameManager.playing_area.enable_hero_card_visibility(true)
