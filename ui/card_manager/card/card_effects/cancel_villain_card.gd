class_name CancelVillain
extends CardEffect

func on_clash(villain: Villain, hero: Hero):
	GameManager.is_current_villain_card_enabled = false
	GameManager.add_log("Villain card is cancelled!")
