@tool
class_name VillainImmune
extends Effect


func _on_clash(
	villain: Villain,
	_hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	villain.immune_to_damage = true


	return outcome


func _clear_effect_data() -> void:
	pass


func _effect_text() -> String:
	return "Villain is immune to damage"
