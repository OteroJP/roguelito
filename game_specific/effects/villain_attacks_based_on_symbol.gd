@tool
class_name VillainAttackSymbol
extends Effect

@export var ignores_armor: bool = false
@export var symbol: Villain.Symbol = Villain.Symbol.NONE
@export var threshold: int = 1
@export var damage_under_threshold: int = 0
@export var damage_over_threshold: int = 1


func _on_clash(
	villain: Villain,
	hero: Hero,
	villain_port: VillainPort,
	_hero_port: HeroPort,
	combat_manager: CombatManager
) -> void:
	if (symbol == Villain.Symbol.NONE or
	villain.symbol_count[symbol] < threshold):
		combat_manager.perform_attack(
			villain_port, hero, damage_under_threshold, ignores_armor
		)
	else:
		combat_manager.perform_attack(
			villain_port, hero, damage_over_threshold, ignores_armor
		)




func _effect_text() -> String:
	var text := "Villain attacks for %d damage if over %s %s, else for %s" % [damage_over_threshold, threshold, Villain.Symbol.keys()[symbol], damage_under_threshold]
	if ignores_armor:
		text += ", ignoring armor"
	return text
