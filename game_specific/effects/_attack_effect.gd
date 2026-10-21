@abstract class_name AttackEffect
extends Effect


## Builds an attack from snapshots taken after preparation has completed.
@abstract func build_attack(context: CombatManager.CombatContext) -> Attack
