@tool
class_name VillainSpeedNext
extends Effect

@export var bonus_speed: int = 0


func _on_clash(
	_villain: Villain,
	_hero: Hero,
	villain_port: VillainPort,
	_hero_port: HeroPort,
	combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	combat_manager.add_speed_bonus(villain_port, bonus_speed)

	return outcome


func _effect_text() -> String:
	var text := "Villain gains +%s speed" % str(bonus_speed)
	return text
