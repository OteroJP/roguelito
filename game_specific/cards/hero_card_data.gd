@tool
class_name HeroCardData
extends CardData

@export var stance_for_bonus: Hero.Stance
@export var stance_after_clash: Hero.Stance
@export var removable: bool = true


func on_play(villain: Villain, hero: Hero) -> AuditOutcome:
	return AuditOutcome.new()


func on_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	var outcome := AuditOutcome.new()
	if hero.is_in_stance(stance_for_bonus):
		outcome.add(AuditEvent.Kind.STANCE_BONUS_TRIGGERED, AuditLogEntry.Source.HERO)
		for effect in bonus_effects:
			outcome.append(await effect.on_clash(villain, hero))
	for effect in effects:
		outcome.append(await effect.on_clash(villain, hero))
	return outcome


func after_clash(villain: Villain, hero: Hero) -> AuditOutcome:
	hero.change_stance(stance_after_clash)
	resolved.emit(self)
	return AuditOutcome.new()


func on_discard(villain: Villain, hero: Hero) -> AuditOutcome:
	return AuditOutcome.new()


func _bonus_color() -> Color:
	return UIAssets.HERO_BONUS_STANCE_COLOR
