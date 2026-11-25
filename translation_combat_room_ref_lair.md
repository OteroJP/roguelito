# Combat Room → Ref Lair translation

`dungeon/assets/art/ref_lair.tscn` is the visual reference for how `main.tscn` should look.
This document shows both trees and the correspondence between them.

Files:

- Current runtime scene: [`main.tscn`](main.tscn)
- Target reference scene: [`dungeon/assets/art/ref_lair.tscn`](dungeon/assets/art/ref_lair.tscn)

---

## Target grouping (`ref_lair.tscn`)

`ref_lair.tscn` is a flat list of reference nodes, but they belong to three visual groups.

```text
RefLair (Node2D)
│
├── [Background]
│   ├── pisoide        (Sprite2D, hidden)
│   ├── columnoides    (Sprite2D, hidden)
│   ├── fonditodo      (Sprite2D)
│   ├── PointLight2D   (energy 16)
│   ├── PointLight2D4  (energy 16)
│   ├── PointLight2D2  (energy 16)
│   ├── PointLight2D3  (energy 16)
│   ├── PointLight2D5  (energy 4.91)
│   ├── PointLight2D6  (energy 4.91)
│   └── PointLight2D7  (energy 4.91)
│
├── [Villain view]
│   ├── RefVillainHandR  (spells + mana bar)
│   ├── RefVillainHandL  (player counters + EstadosV01)
│   ├── RefPlayerCard    (card hand)
│   └── EstadosV01       (Sprite2D, 6 frames — belongs to player counters)
│
└── [Hero view]
    ├── RefHeroe        (hero visual)
    └── RefHealthbar    (hero health bar)
```

---

## Current tree (`main.tscn`)

Nodes marked `[runtime]` are not written in the `.tscn`; they are instantiated from code
(`game_specific/combat_room.gd`, `hero_visual_adapter.gd`, `villain_visual_adapter.gd`,
`agnostic/audit/logger.gd`).

```text
Control  [script: combat_room.gd]
│
├── GameLogger                    [runtime, child of root]
│   └── CombatLog                 [runtime]
├── TextureRect                   (hidden, ViewportTexture)
│
├── SubViewportContainer
│   └── SubViewport (640×360)
│       ├── DungeonRoom           = ref_lair.tscn instance
│       │   └── HeroVisuals       [runtime, scenes/hero_visuals.tscn]
│       │       ├── Art           (hero sprite)
│       │       ├── CollisionShape2D
│       │       └── VBoxContainer (Name, Statuses, Damage, ArmorBar, HealthBar…)
│       └── Camera2D
│
└── HBoxContainer                 (actually a VBoxContainer)
    ├── PlayingArea               = scenes/playing_area.tscn
    │   └── PlayingColumn
    │       ├── CardSlotOne (+ Content, CancelledOverlay)
    │       └── CardSlotTwo (+ Content, CancelledOverlay)
    └── InteractiveContainer      (MarginContainer)
        └── VillainVisuals        [runtime, scenes/villain_visuals.tscn]
            ├── StatsAndAbilities
            │   ├── DeckContainer/Deck
            │   ├── StatusContainer/Statuses
            │   ├── HealthContainer (Health, HealthLabel)
            │   ├── ManaContainer (ManaDelta, Mana, ManaLabel)
            │   └── DiscardContainer/Discard
            ├── Separator/MarginContainer/VBoxContainer/Spellbook
            ├── HandContainer
            │   ├── Hand          (card hand)
            │   ├── Buttons       (ConfirmButton, CancelButton)
            │   └── SpellConfirmBtn
            ├── VBoxContainer
            │   ├── Symbols       (CurrentSymbol, SymbolCompleted)
            │   ├── Label         ("CURRENT SYMBOL")
            │   └── SymbolCounters
            └── Control           (hidden viewport helper)
```

---

## Correspondence

### Background

The background is already in place: `main.tscn` instantiates `ref_lair.tscn` itself
(`SubViewportContainer/SubViewport/DungeonRoom`), so all background nodes are the same nodes.

| `ref_lair.tscn` | `main.tscn` |
|---|---|
| `pisoide`, `columnoides`, `fonditodo`, `PointLight2D…7` | Same nodes, via the `DungeonRoom` instance. No translation needed. |

### Villain view

The current villain UI is the `VillainVisuals` scene added under `InteractiveContainer`.
The target regroups it around `RefVillainHandR` / `RefVillainHandL` / `RefPlayerCard`.

| `ref_lair.tscn` | Current `main.tscn` node(s) |
|---|---|
| `RefVillainHandR` — spells | `InteractiveContainer/VillainVisuals/Separator/MarginContainer/VBoxContainer/Spellbook` |
| `RefVillainHandR` — mana bar (moved here) | `InteractiveContainer/VillainVisuals/StatsAndAbilities/ManaContainer` (`ManaDelta`, `Mana`, `ManaLabel`) |
| `RefVillainHandL` — player counters | `InteractiveContainer/VillainVisuals/VBoxContainer/SymbolCounters` |
| `EstadosV01` — player counters icons | Current status icons: `InteractiveContainer/VillainVisuals/StatsAndAbilities/StatusContainer/VBoxContainer/Statuses` (inference) |
| `RefPlayerCard` — card hand | `InteractiveContainer/VillainVisuals/HandContainer/Hand` (inference) |

### Hero view

The current hero UI is the `HeroVisuals` scene added at runtime under `DungeonRoom`.

| `ref_lair.tscn` | Current `main.tscn` node(s) |
|---|---|
| `RefHeroe` | `DungeonRoom/HeroVisuals/Art` (+ root `Hero` Area2D, `CollisionShape2D`) |
| `RefHealthbar` | `DungeonRoom/HeroVisuals/VBoxContainer/Health/CenterContainer/HealthBar` (+ `HealthLabel`) |

---

## Current nodes with no replacement in `ref_lair.tscn`

| Current node | Status |
|---|---|
| `GameLogger` / `CombatLog` (runtime children of the root `Control`) | No replacement yet |
| `HBoxContainer/PlayingArea` (`CardSlotOne`, `CardSlotTwo`) | No replacement yet |
| `VillainVisuals/VBoxContainer/Symbols` (`CurrentSymbol`, `SymbolCompleted`) | No replacement yet |

### Other current-only pieces (not covered by the reference)

These also have no dedicated node in `ref_lair.tscn`; listed for completeness, not yet decided:

- `TextureRect` (hidden `ViewportTexture` copy)
- `StatsAndAbilities/HealthContainer` (villain health — `RefHealthbar` is the hero's)
- `StatsAndAbilities/DeckContainer/Deck`, `DiscardContainer/Discard`
- `HandContainer/Buttons` (`ConfirmButton`, `CancelButton`) and `SpellConfirmBtn`
- `VillainVisuals/Control` (hidden viewport helper)

---

# Migration plan

## Constraints to solve first

1. **`Node2D` vs `Control`.** [`ref_lair.tscn`](dungeon/assets/art/ref_lair.tscn) is almost
   entirely `Node2D` (`Sprite2D`, `PointLight2D`), while [`main.tscn`](main.tscn) is a `Control`
   tree. The target mixes both: some UI is diegetic (belongs in the 2D world) and some is plain
   screen-space HUD.
2. **Viewport and scene root.** [`main.tscn`](main.tscn) uses `Control` →
   `SubViewportContainer` → `SubViewport` (640×360) → `DungeonRoom` + `Camera2D`. The 2D world
   already lives inside the SubViewport, and `ref_lair.tscn` is the `DungeonRoom` instance, so
   its lights already do not affect the HUD. The question is where the *new* diegetic UI lives
   and how input/layout works there.
3. **Diegetic UI → split villain view.** The current `VillainVisuals` (HBoxContainer) is added
   under `%InteractiveContainer`, outside the SubViewport. If spells, mana, counters and the
   card hand become diegetic, they must move inside the SubViewport, so the villain view has to
   be split into a world part and a HUD part. That requires code changes in the adapters, not
   only scene edits.
4. **Card scenes and card code are being replaced.** The old `Node2D` reference is now
   [`assets/villain/art/old_ref_villain_card.tscn`](assets/villain/art/old_ref_villain_card.tscn);
   the former `ref_player_card` is now
   [`assets/villain/art/ref_villain_card.tscn`](assets/villain/art/ref_villain_card.tscn)
   (a `Control` with the panel UI); and the production scene now lives at
   [`scenes/villain_card.tscn`](scenes/villain_card.tscn), replacing the old card scene. `Card`
   ([`dungeon/cards/card.gd`](dungeon/cards/card.gd)) now extends `Control`, so it can be
   attached to the production scene's `Control` root. On the hero side,
   [`assets/hero/art/ref_hero_card.tscn`](assets/hero/art/ref_hero_card.tscn) is the reference
   and has no production copy yet.

## How to read the groups

- **Difficulty**: amount and risk of code change, not time.
- **Impact**: visible result and how much it unblocks later groups.
- Groups are ordered by *do this first*: low difficulty / high value first, structural work
  after, design-dependent work last.

## Group 2 — Card views (Low–Medium difficulty, High impact)

First visible change; testable in [`main.tscn`](main.tscn) without touching the rest of the
layout. The card views are being rebuilt around:

- Villain: [`scenes/villain_card.tscn`](scenes/villain_card.tscn) (uid
  `uid://c6pnj4405qqg7`), derived from
  [`assets/villain/art/ref_villain_card.tscn`](assets/villain/art/ref_villain_card.tscn).
  The old `Node2D` reference is kept at
  [`assets/villain/art/old_ref_villain_card.tscn`](assets/villain/art/old_ref_villain_card.tscn).
- Hero: [`assets/hero/art/ref_hero_card.tscn`](assets/hero/art/ref_hero_card.tscn)
  (uid `uid://5e31f4ehjbf1`), which still needs a production copy.

### Step 2.1 — Card text API in the data layer (done)

Target: [`game_specific/cards/_card_data.gd`](game_specific/cards/_card_data.gd), with
consequences in [`game_specific/cards/hero_card_data.gd`](game_specific/cards/hero_card_data.gd)
and [`game_specific/cards/villain_card_data.gd`](game_specific/cards/villain_card_data.gd).

Implemented:

- `effect_text()` returns the lines from `effects`, followed by `extra_text` when non-empty.
- `bonus_effect_text()` returns the lines from `bonus_effects`.
- Removed `card_text` and its inspector machinery: `_watch_effects`, `_watch_effect`,
  `_queue_refresh`, `_refresh_inspector`, and the `card_text` branches in
  `_get`/`_set`/`_validate_property`.
- Removed the now-unused `_bonus_color()` overrides from
  [`hero_card_data.gd`](game_specific/cards/hero_card_data.gd) and
  [`villain_card_data.gd`](game_specific/cards/villain_card_data.gd).
- Kept `@tool` and the editor-only effect localization in `_effects_for_card`/`_init`; it no
  longer drives an inspector property.
- Effect text is returned as-is, including the BBCode color tags some effects use. The card
  labels are `RichTextLabel`, so the tags render.
- [`dungeon/cards/hero_card.gd`](dungeon/cards/hero_card.gd) now uses both methods through
  `_compose_text()` (regular text plus the bonus block in `HERO_BONUS_STANCE_COLOR`) until
  step 2.3 rebuilds the hero scene.

**Test:** headless instantiation of `VillainCard` with effects produced `Opponent heals 3` and
`Opponent heals 5` in the effect and bonus labels.

### Step 2.2 — Villain card scene + script (done)

- Moved `assets/villain/art/villain_card.tscn` to
  [`scenes/villain_card.tscn`](scenes/villain_card.tscn), replacing the previous scene. The old
  scene (uid `uid://ce3fqp227u3vc`) no longer exists.
- Attached [`dungeon/cards/villain_card.gd`](dungeon/cards/villain_card.gd) to the scene;
  `CARD_SCENE` is now `uid://c6pnj4405qqg7`.
- Changed `Card` ([`dungeon/cards/card.gd`](dungeon/cards/card.gd)) from `PanelContainer` to
  `Control`, matching the scene root and keeping the old hero scene (a `PanelContainer`) valid.
- Renamed the root from `RefPlayerCard` to `VillainCard`.
- Renamed the content container to `Content`, marked it `unique_name_in_owner`, and replaced
  `$MarginContainer` with `%Content` in the script.
- Converted `%Effect` and `%BonusEffect` to `RichTextLabel` with `bbcode_enabled = true`, so the
  existing effect color tags render.
- Added `custom_minimum_size = Vector2(74, 124)` and size flags for hand layout, and
  reconnected the `mouse_entered` / `mouse_exited` signals.
- Kept the script (it was not deleted) and kept `light_mask = 0`, so cards stay unlit.

**Test:** headless instantiation loads `res://scenes/villain_card.tscn` and binds the speed,
effect, and bonus-effect labels.

### Step 2.3 — Hero card scene + script

Target: [`dungeon/cards/hero_card.gd`](dungeon/cards/hero_card.gd) and a new production scene
sibling to [`assets/hero/art/ref_hero_card.tscn`](assets/hero/art/ref_hero_card.tscn)
(duplicate it, for example as `assets/hero/art/hero_card.tscn`).

- Duplicate the reference scene and add the unique-name nodes the script needs, following the
  villain pattern.
- Attach `hero_card.gd` and change `CARD_SCENE` from
  [`scenes/hero_card.tscn`](scenes/hero_card.tscn) (uid `uid://yn4vjcemn7yh`) to the new scene.
- Map the script's nodes: `%Ilustration` (`TextureRect` with `card_hero_art.png`), `%Effect` and
  `%BonusEffect` (`RichTextLabel`, like the villain card), `%SpeedLabel`, `%Title`, and the
  stance symbol (`TextureRect2` in the reference). The reference has no title and no
  `%CardBack`; add/rename nodes or adjust the script.
- Replace the temporary `_compose_text()` bridge with direct `effect_text()` /
  `bonus_effect_text()` bindings to the two labels.
- `enable_visibility()` toggles `%CardBack`; decide whether the hero card keeps a card back
  (add the node) or the method becomes a no-op/guard.
- Keep `new_hero_card`, `select_card`, `match_data`, hover, and the `card_clicked` contract.

**Test:** the hero hand renders the new card; reveal/visibility, hover and selection work.

### Step 2.4 — Shared card behavior parity

- Both cards: root `mouse_filter = STOP`, content `MOUSE_FILTER_IGNORE`,
  `offset_transform_enabled`/`offset_transform_visual_only`, hover tween on
  `offset_transform_position`, and `set_process_input(false)` from the factory.
- Confirm z-ordering/scale of the reference scenes (e.g. `z_index = 1`, card ratios) still
  give sensible hand layouts.
- [`dungeon/cards/card_view_factory.gd`](dungeon/cards/card_view_factory.gd) should not need
  changes if `new_villain_card` / `new_hero_card` keep their signatures.
- Check callers: `VillainVisuals` and `HeroVisuals` (`match_data`, `enable_visibility`,
  `card_clicked`).

### Step 2.5 — Runtime validation in `main.tscn`

Do this before removing the old scenes. Checklist:

- combat starts and both hands draw;
- hover animation and mouse click selection;
- effect and bonus-effect text match the data for hero and villain cards;
- symbols (villain) and stance (hero) show the right textures;
- no missing-node errors in the output;
- other views are unchanged.

### Step 2.6 — Retire the old hero card scene

- The old villain scene was already replaced during step 2.2.
- Once step 2.5 passes, remove or mark deprecated
  [`scenes/hero_card.tscn`](scenes/hero_card.tscn).
- Keep [`assets/villain/art/old_ref_villain_card.tscn`](assets/villain/art/old_ref_villain_card.tscn)
  and [`assets/villain/art/ref_villain_card.tscn`](assets/villain/art/ref_villain_card.tscn) as
  references; rename the hero reference once its production copy exists.

## Group 3 — Hero view → `ref_heroe` / `ref_healthbar` (Medium difficulty, Medium impact)

The hero view is already inside the SubViewport (`HeroVisuals` is added under `DungeonRoom`),
so this does not depend on the viewport split.

- Replace `HeroVisuals/Art` (`Sprite2D`) with
  [`assets/hero/art/ref_heroe.tscn`](assets/hero/art/ref_heroe.tscn) (`Node2D` + `Sprite2D`).
- Replace `HeroVisuals/VBoxContainer/Health/CenterContainer/HealthBar` and its label with
  [`assets/hero/art/ref_healthbar.tscn`](assets/hero/art/ref_healthbar.tscn) (`Control` +
  `TextureProgressBar` + `Label`).
- Align transforms with `RefHeroe` / `RefHealthbar` in
  [`dungeon/assets/art/ref_lair.tscn`](dungeon/assets/art/ref_lair.tscn).
- Keep [`dungeon/character/hero_visuals.gd`](dungeon/character/hero_visuals.gd) API (`update`,
  `change_stance`, `play_card`, `restore_statuses`).

**Test:** hero sprite and health bar look correct, damage/heal updates still animate.

## Group 4 — Viewport and scene-root split (High difficulty, High impact)

The structural decision. Everything else depends on it.

- **Root:** decide whether `main.tscn` stays `Control` (screen UI) with a `SubViewport` world, or
  becomes `Node2D`. Current setup already works; changing the root is optional unless the
  diegetic layout demands it.
- **Layer contract:**
  - Inside the SubViewport: `Node2D` world + diegetic `Control` UI.
  - Outside: screen-space HUD only.
  - Use `light_mask` / `CanvasLayer` so lights affect the world and diegetic UI but not the HUD.
- **Split `VillainVisuals`** into, for example, `VillainWorldView` (parented under
  `%DungeonRoom`) and `VillainHud` (parented under `%InteractiveContainer`).
- **Code touch points:**
  - [`game_specific/combat_room.gd`](game_specific/combat_room.gd): `@onready`
    `%InteractiveContainer`, `%DungeonRoom`, `%PlayingArea`; `_prepare_room()` creates
    `HeroVisualAdapter.new(hero, dungeon)` and `VillainVisualAdapter.new(villain, villain_container)`.
  - [`game_specific/ports/villain_visual_adapter.gd`](game_specific/ports/villain_visual_adapter.gd):
    `visual_parent.add_child(...)`.
  - [`game_specific/ports/hero_visual_adapter.gd`](game_specific/ports/hero_visual_adapter.gd):
    visual parent is `dungeon`.
- **Watch:** SubViewport is 640×360 with `size_2d_override_stretch = true`; Controls inside it
  lay out in viewport resolution, not screen resolution. Input must still reach the cards and
  spell buttons through the `SubViewportContainer` (`mouse_target`, `handle_input_locally = false`).
  Camera transforms also affect diegetic UI positions.

**Test:** world renders as before; HTML-scale HUD is unaffected by the lights; input reaches
diegetic cards/spells; window resize keeps the layout sane.

## Group 5 — Diegetic villain view content (High difficulty, High impact)

After the split, move the villain UI pieces into the reference positions.

| Target | Content to migrate |
|---|---|
| `RefVillainHandR` | spells (`Spellbook`), mana bar (`ManaContainer`: `ManaDelta`, `Mana`, `ManaLabel`) |
| `RefVillainHandL` | player counters (`SymbolCounters`), status icons (`EstadosV01`) |
| `RefPlayerCard` | card hand (`HandContainer/Hand`) |

- Convert the current `Control` widgets (VBox `Spellbook`, `ProgressBar`, `HBoxContainer`
  counters) into the world-space/diegetic layout, or keep them as `Control` nodes inside the
  SubViewport and mask them correctly.
- Split the data binding in
  [`dungeon/character/villain_visuals.gd`](dungeon/character/villain_visuals.gd) between the
  world view and the HUD; keep `refresh_stats`, `add_to_hand`, spell selection, and symbol
  updates working.
- Map `EstadosV01` frames to the status icons currently built in `Statuses`.
- Do one element at a time (spells → mana → counters → card hand), testing each.

**Test:** each element matches the reference position, updates during combat, and is lit by
the room lights without leaking onto the HUD.

## Group 6 — Unresolved areas (Design-dependent, Medium difficulty)

No reference in `ref_lair.tscn`; decide before building.

- **Log** (`GameLogger` + `CombatLog`, created at runtime in
  [`game_specific/combat_room.gd`](game_specific/combat_room.gd)): HUD or diegetic? If
  diegetic, it needs a position inside the SubViewport.
- **`PlayingArea`** ([`scenes/playing_area.tscn`](scenes/playing_area.tscn): `CardSlotOne`,
  `CardSlotTwo`): keep, relocate, or retire.
- **Symbols** (`VillainVisuals/VBoxContainer/Symbols`: `CurrentSymbol`, `SymbolCompleted`):
  choose a home, possibly near the player counters.
- Decide whether the hidden `TextureRect` (ViewportTexture) and `VillainVisuals/Control`
  helper stay or are removed.

## Group 7 — Cleanup (Low difficulty, Low impact)

- Rename production scenes out of `ref_*`; keep
  [`dungeon/assets/art/ref_lair.tscn`](dungeon/assets/art/ref_lair.tscn) (or a copy) as the
  visual reference.
- Remove dead nodes and old card/UI scenes that are no longer referenced.
- Update this document and the manual test checklist.

## Recommended order

1. Group 2 — cards (first visible, independently testable in `main.tscn`):
   2.1 text API (done) → 2.2 villain scene (done) → 2.3 hero scene → 2.4 parity →
   2.5 validation → 2.6 retirement.
2. Group 3 — hero view.
3. Group 4 — viewport / scene-root split.
4. Group 5 — diegetic villain view.
5. Group 6 — unresolved areas.
6. Group 7 — cleanup.

Groups 2–3 can run before the split and give visible progress. Step 2.1 gates 2.2 and 2.3;
2.2 and 2.3 can be done in either order. Group 4 is the gate for Group 5 and should be done on
its own, with the old `VillainVisuals` path kept working until the split is verified.
