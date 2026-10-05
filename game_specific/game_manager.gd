extends Node

enum LogSource { HERO, VILLAIN, GAME }

const _LOG_COLOR: Dictionary[LogSource, String] = {
	LogSource.HERO: "#8ec8ff",
	LogSource.VILLAIN: "#ff7a7a",
	LogSource.GAME: "#f0d078",
}
const _LOG_TAG: Dictionary[LogSource, String] = {
	LogSource.HERO: "HERO",
	LogSource.VILLAIN: "VILLAIN",
	LogSource.GAME: "GAME",
}

var villain: Villain
var hero: Hero
#TODO These should be tuples?
var current_villain_card: VillainCardData
var is_current_villain_card_enabled: bool = true
var current_hero_card: HeroCardData
var is_current_hero_card_enabled: bool = true
var card_resolve_queue: Array[CardData]
var playing_area: PlayingArea
var ux_delay: float
var _log: CombatLog


func prepare(_playing_area: PlayingArea, _hero: Hero, _villain: Villain, _ux_delay: float) -> void:
	playing_area = _playing_area
	hero = _hero
	villain = _villain
	ux_delay = _ux_delay


func sort_cards() -> void:
	card_resolve_queue = _sort_cards_by_fastest()	
	

func play_villain_card(card: VillainCardData) -> void:
	current_villain_card = card
	card.on_play(villain, hero)
	await playing_area.update()
	await get_tree().create_timer(GameManager.ux_delay).timeout


func play_hero_card(card: HeroCardData) -> void:
	current_hero_card = card
	card.on_play(villain, hero)
	await playing_area.update()
	await get_tree().create_timer(GameManager.ux_delay).timeout


func execute_faster_card() -> void:
	#TODO this could be cleaner
	if (card_resolve_queue[0] == current_villain_card):
		if current_villain_card_enabled():
			GameManager.add_debug("VILLAIN GOES FIRST:", LogSource.VILLAIN)
			await playing_area.resolve_villain_card()
			await current_villain_card.on_clash(villain, hero)
		else:
			GameManager.add_debug("VILLAIN WAS CANCELLED!:", LogSource.VILLAIN)
	if (card_resolve_queue[0] == current_hero_card):
		if current_hero_card_enabled():
			GameManager.add_debug("HERO GOES FIRST:", LogSource.HERO)
			await playing_area.resolve_hero_card()
			await current_hero_card.on_clash(villain, hero)
		else:
			GameManager.add_debug("HERO WAS CANCELLED!:", LogSource.HERO)
	await playing_area.update()
	await get_tree().create_timer(GameManager.ux_delay).timeout


func execute_slower_card() -> void:
	#TODO this could be cleaner
	if (card_resolve_queue[1] == current_villain_card):
		if is_current_villain_card_enabled:
			GameManager.add_debug("VILLAIN GOES SECOND:", LogSource.VILLAIN)
			await playing_area.resolve_villain_card()
			await current_villain_card.on_clash(villain, hero)
		else:
			GameManager.add_debug("VILLAIN WAS CANCELLED!", LogSource.VILLAIN)
	if (card_resolve_queue[1] == current_hero_card):
		if is_current_hero_card_enabled:
			GameManager.add_debug("HERO GOES SECOND:", LogSource.HERO)
			await playing_area.resolve_hero_card()
			await current_hero_card.on_clash(villain, hero)
		else:
			GameManager.add_debug("HERO WAS CANCELLED!", LogSource.HERO)
	await playing_area.update()
	await get_tree().create_timer(GameManager.ux_delay).timeout
	
	
func end_phase() -> void:
	for card in card_resolve_queue:
		card.after_clash(villain, hero)
	hero.end_phase()
	await villain.end_phase()
	await get_tree().create_timer(GameManager.ux_delay).timeout


func _sort_cards_by_fastest() -> Array[CardData]:
	var sorted_cards: Array[CardData]
	if (current_hero_card.speed + hero.speed_bonus) > (current_villain_card.speed + villain.speed_bonus):
		sorted_cards = [current_hero_card, current_villain_card]
	else:
		sorted_cards = [current_villain_card, current_hero_card]
	return sorted_cards


func _ready() -> void:
	_log = CombatLog.new()
	add_child(_log)
	_log.set_legend(
		"[color=%s]HERO[/color]   [color=%s]VILLAIN[/color]   [color=%s]GAME[/color]    F1 toggles" % [
			_LOG_COLOR[LogSource.HERO],
			_LOG_COLOR[LogSource.VILLAIN],
			_LOG_COLOR[LogSource.GAME],
		]
	)


func clear_log() -> void:
	_log.clear()


func add_debug(line: String, source: LogSource = LogSource.GAME) -> void:
	_log.append(line, _LOG_COLOR[source], _LOG_TAG[source])


func current_villain_card_enabled() -> bool:
	return is_current_villain_card_enabled
	
	
func current_hero_card_enabled() -> bool:
	return is_current_hero_card_enabled
