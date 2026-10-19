@tool
class_name VillainPierce
extends Effect


func _on_clash(
	_villain: Villain,
	_hero: Hero,
	villain_port: VillainPort,
	_hero_port: HeroPort,
	combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	var pierce_modifier: PierceModifier = PierceModifier.new()
	combat_manager.add_attack_modifier(villain_port, pierce_modifier)


	return outcome


func _effect_text() -> String:
	return "Villain's attacks ignore armor"
