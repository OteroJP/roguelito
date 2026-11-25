# Game loop

## Objective

Separate the run loop from the combat scene. The game starts in a main menu, and a run is
an endless sequence of combat → rest → combat until the hero is defeated in combat. The
combat room is only the active scene while a combat is running.

Current state: [`project.godot`](project.godot) runs [`main.tscn`](main.tscn) directly, and
[`game_specific/combat_room.gd`](game_specific/combat_room.gd) starts a combat as soon as the
scene is ready.

## Target flow

```
main_menu ──"Nueva partida"──▶ RunController.start_run()
                                    │
                                    ▼
                          combat_room (scenes/combat_room.tscn)
                                    │
                       hero defeated │ villain defeated
                            │        │
                            ▼        ▼
                     main_menu     rest_room (full heal)
                                     │ "Continuar"
                                     ▼
                               next combat_room
```

## Pieces

- **`RunOptions`** ([`game_specific/run/run_options.gd`](game_specific/run/run_options.gd)):
  hero, villain, end conditions and the `headless` flag. The `RunController` creates it and
  the combat room consumes it.
- **`RunController`** (autoload, [`game_specific/run/run_controller.gd`](game_specific/run/run_controller.gd)):
  owns the active `RunOptions` for the whole run, switches scenes and decides what follows a
  combat.
- **Combat room** ([`scenes/combat_room.tscn`](scenes/combat_room.tscn), formerly `main.tscn`):
  builds its adapters from the characters received in `RunOptions` and uses its end
  conditions. It does not decide the outcome.
- **Main menu** ([`scenes/main_menu.tscn`](scenes/main_menu.tscn)): black screen with
  "Nueva partida" and "Salir".
- **Rest room** ([`scenes/rest_room.tscn`](scenes/rest_room.tscn)): shows the hero and lets
  the player continue to the next combat.

## Decisions

- **Menu:** only "Nueva partida" and a quit button. No other options yet.
- **Villain:** the same villain for the whole run, and it is not healed between combats.
  When it is defeated it starts the next combat at full health (otherwise the next combat
  would end immediately).
- **Rest:** fully heals the hero. Upgrades are not implemented yet; the rest is the place
  where they will happen.
- **Run end:** endless. The run ends only when the hero is defeated, which returns to the
  main menu.
- **Headless:** `RunOptions.headless` selects the headless resolution port
  ([`game_specific/ports/headless_combat_adapter.gd`](game_specific/ports/headless_combat_adapter.gd))
  instead of the visual one. Default is visual (`headless = false`).
- **Ownership:** the `RunController` creates the characters and the end conditions; the
  combat room receives them through `RunOptions` and creates the adapters from them.
- **Combat end:** `CombatRoom._end_combat()` does not determine the result. It only calls
  `RunController.finish_combat()`, and the controller reads the end conditions to choose
  rest or main menu.
- **Scene name:** [`main.tscn`](main.tscn) is renamed to
  [`scenes/combat_room.tscn`](scenes/combat_room.tscn). The scene uid is kept, so existing
  references by uid keep working.

## Files

| Action | Path |
|---|---|
| add | [`game_specific/run/run_options.gd`](game_specific/run/run_options.gd) |
| add | [`game_specific/run/run_controller.gd`](game_specific/run/run_controller.gd) |
| add | [`scenes/main_menu.tscn`](scenes/main_menu.tscn), [`game_specific/menu/main_menu.gd`](game_specific/menu/main_menu.gd) |
| add | [`scenes/rest_room.tscn`](scenes/rest_room.tscn), [`game_specific/rest/rest_room.gd`](game_specific/rest/rest_room.gd) |
| move | [`main.tscn`](main.tscn) → [`scenes/combat_room.tscn`](scenes/combat_room.tscn) |
| change | [`game_specific/combat_room.gd`](game_specific/combat_room.gd) |
| change | [`game_specific/end_conditions/character_defeated.gd`](game_specific/end_conditions/character_defeated.gd) (expose the character) |
| change | [`project.godot`](project.godot) (main scene + `RunController` autoload) |
| remove | [`game_specific/loops/game_run.gd`](game_specific/loops/game_run.gd) (unused stub) |

## Steps

1. Move `main.tscn` to `scenes/combat_room.tscn` and keep its uid.
2. Add `RunOptions` and `RunController`; register the autoload.
3. Wire the combat room to `RunOptions`: characters for the adapters, end conditions for
   the loop, headless or visual combat port, and `RunController.finish_combat()` in
   `_end_combat()`. Keep the exported hero/villain as a standalone fallback so the combat
   scene can still be run on its own.
4. Add the main menu scene and script.
5. Add the rest room scene and script.
6. Point `project.godot` at the main menu.
7. Validate: menu → combat → rest → combat → defeat → menu.

## Open points

- A new run starts with the health authored in [`resources/hero.tres`](resources/hero.tres)
  (4/7), not at full health.
- Headless combat still creates the visual character adapters; only the resolution port is
  headless. Fully headless characters need headless `HeroPort` / `VillainPort`
  implementations.
