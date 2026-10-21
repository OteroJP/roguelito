class_name CardViewFactory
extends RefCounted


static func create_card_view(card_data: CardData) -> Card:
	if card_data is HeroCardData:
		return HeroCard.new_hero_card(card_data as HeroCardData)
	if card_data is VillainCardData:
		return VillainCard.new_villain_card(card_data as VillainCardData)
	assert(false, "CardViewFactory only supports HeroCardData and VillainCardData.")
	return null
