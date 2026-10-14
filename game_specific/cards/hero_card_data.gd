@tool
class_name HeroCardData
extends CardData

@export var stance_for_bonus: Hero.Stance
@export var stance_after_clash: Hero.Stance
@export var removable: bool = true


func on_play(
	_villain: Villain,
	_hero: Hero,
	_villain_port: VillainPort,
	_hero_port: HeroPort,
	_combat_manager: CombatManager
) -> AuditOutcome:
	return AuditOutcome.new()


func on_clash(
	villain: Villain,
	hero: Hero,
	villain_port: VillainPort,
	hero_port: HeroPort,
	combat_manager: CombatManager
) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if hero.is_in_stance(stance_for_bonus):
		outcome.add(AuditEvent.Kind.STANCE_BONUS_TRIGGERED, AuditLogEntry.Source.HERO)
		outcome.append(await combat_manager.run_effect_batch(bonus_effects, villain_port, hero_port))
	outcome.append(await combat_manager.run_effect_batch(effects, villain_port, hero_port))
	return outcome


func after_clash(_villain: Villain, _hero: Hero) -> AuditOutcome:
	resolved.emit(self)
	return AuditOutcome.new()


func on_discard(villain: Villain, hero: Hero) -> AuditOutcome:
	return AuditOutcome.new()


func _bonus_color() -> Color:
	return UIAssets.HERO_BONUS_STANCE_COLOR
