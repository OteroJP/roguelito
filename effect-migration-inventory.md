# Effect Migration Inventory (Macrostep 4)

Baseline: working tree after the effect-lifecycle experiment. `_attack_effect.gd` no longer exists; all concrete effects now extend `Effect` directly. `Attack` building is done via `build_attack()` on any `Effect` with `target_side`.

## New lifecycle contract (`_effect.gd`)

- `prepare(owner, owner_port) -> bool` — runs on the source character; may request interaction.
- `apply(target) -> bool` — applies to the target character.
- `combat_state_changes(owner) -> Array[CombatStateChange]` — combat-owned changes.
- `build_attack(owner, target) -> Attack` — for attack effects.
- `target_side: OWNER | OPPONENT` (default `OPPONENT`).
- `requests_hero_card_reveal() -> bool`.

## Current concrete effects

### Attacks (likely use `build_attack`)
- `hero_attacks_basic.gd` (HeroAttacksBasic)
- `hero_attacks_armor.gd` (HeroAttacksPerArmor)
- `attack_for_damage.gd` (AttackForDamage)
- `villain_attacks_based_on_armor.gd` (VillainAttackArmor)
- `villain_attacks_based_on_hero_dmg.gd` (VillainAttackHeroDamage)
- `villain_attacks_based_on_symbol.gd` (VillainAttackSymbol)
- `villain_attacks_with_health_cost.gd` (VillainAttackHealthCost)

### Damage / armor
- `hero_take_damage.gd`
- `set_hero_armor.gd`
- `set_hero_health_threshold.gd`
- `hero_armors.gd`
- `villain_make_pierce.gd`
- `villain_modify_damage.gd`

### Healing
- `character_heals.gd`
- `villain_heals_based_on_symbol.gd`

### Statuses
- `character_takes_status.gd`
- `villain_take_status_if_symbol.gd`
- `hero_remove_status.gd`

### Speed / symbols
- `character_speed_bonus.gd`
- `villain_speed_next_cards.gd`

### Interaction / selection
- `cancel_selected_card.gd`
- `villain_takes_from_discard.gd`
- `reveal_hero_card.gd`

### Other
- `hero_improve_stat.gd`
- `villain_draws.gd`

## Migration status
- [ ] Each effect implements `prepare()` where it needs owner-side changes/interaction.
- [ ] Each attack effect implements `build_attack()`.
- [ ] Each effect implements `apply()` for target-side changes.
- [ ] Interaction path defined (replaces removed `_ask_for_interaction()`).
- [ ] `.tres` resources rewired to migrated scripts.
- [ ] No references to removed `CombatManager` methods (e.g. `perform_attack()`).

## Notes
- Many original concrete effects were deleted; new generic replacements (`character_*`) are being introduced. Consolidation is in progress.
- Interaction design is still open (see `new-refactor.md` open questions).
