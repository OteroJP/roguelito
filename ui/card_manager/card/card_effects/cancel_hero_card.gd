class_name CancelHero
extends CardEffect

func on_clash(villain: Villain, hero: Hero):
	GameManager.is_current_hero_card_enabled = false
	GameManager.add_log("Hero card is cancelled!")
