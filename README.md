# Project Hearthline

Working title: **Project Hearthline**.

Genre: top-down survival automation sandbox. The game combines the lonely pressure of survival, the satisfying speed of gathering and base expansion, and the pleasure of building production chains, while avoiding direct cloning of any single reference. The core idea: the player survives in a living world, builds a camp, automates gathering and production, explores biomes, and keeps the system from falling apart.

## Current Technical Direction

- Engine: Godot.
- Recommended branch for development: **Godot 4.6.x stable**.
- According to the official Godot archive, the latest stable version on May 18, 2026 was **Godot 4.6.2-stable**.
- Local check: **Godot 4.3.stable.official** was detected earlier, but the old path `/Applications/Godot.app/Contents/MacOS/Godot` is no longer valid.
- View: 2D top-down.
- Prototype language: GDScript.

## Documentation

Start here:

- [Documentation Index](docs/INDEX.md)
- [Versions and Tools](docs/00-version-and-tools.md)
- [Game Vision](docs/01-vision.md)
- [Game Design Document](docs/02-game-design-document.md)
- [Systems Design](docs/03-systems-design.md)
- [Godot Technical Design](docs/04-technical-design.md)
- [Data and Balance](docs/05-data-balance.md)
- [World Generation](docs/06-world-generation.md)
- [UI/UX and Controls](docs/07-ui-ux.md)
- [Art and Audio](docs/08-art-audio.md)
- [Production Roadmap](docs/09-production-roadmap.md)
- [Testing and Release](docs/10-testing-release.md)
- [Backlog](docs/11-backlog.md)
- [Decisions, Risks, and Questions](docs/12-decisions-and-risks.md)
- [Code and Scene Standards](docs/13-coding-standards.md)
- [Content Pipeline](docs/14-content-pipeline.md)
- [Agent Session Instructions](AGENTS.md)
- [Prototype TODO](TODO.md)
- [Changelog](CHANGELOG.md)

## Next Goal

Build a vertical prototype on one small map:

- the player moves, gathers resources, and survives;
- basic construction exists;
- 1-2 automation chains exist;
- there is a day/night cycle and at least one threat;
- world state can be saved and loaded.

## Current Prototype

The project currently has the first Godot skeleton:

- a 150x150 tile map;
- a dynamic time-of-day cycle with Morning, Day, Evening, and Night phases;
- a HUD clock that shows the current day, phase, and 24-hour time;
- world tinting that shifts as the day moves into evening and night;
- a crash-landing premise where the player starts with only a Multitool Cutter from the escape capsule supplies;
- procedural placement of trees, stone, ore, and wild crops;
- a player with top-down movement;
- a starting Multitool Cutter that only stays active while the use button is held on valid targets, outlines the current target, and applies gradual cutting damage;
- destroyed resources drop items onto the ground;
- nearby ground items are picked up if the inventory has space;
- a slot-based inventory with a visible HUD panel;
- a visible 9-slot toolbelt with the starting Multitool Cutter locked in slot 1;
- a full inventory window toggled with Tab or I;
- inventory window categories for Inventory, Building, Upgrades, and Main Menu;
- inventory and station windows are mutually exclusive, and open blocking UI stops movement and automatic pickup;
- a left-side character equipment panel with Helmet, Armor, Gloves, Boots, Belt, and Amulet slots;
- building slots for Furnace, Forge, Workbench, and Fence;
- placeable 2x2 Furnace, Forge, and Workbench placeholders, plus a placeable 1x1 Fence;
- building placement rejects occupied resource, building, and dynamic blocker cells such as the player;
- buildings have prototype health and drop partial refund items when destroyed;
- station UI that opens with E when the cursor is over a nearby Furnace, Forge, or Workbench;
- station input/output slots with Load, Craft, and Collect Outputs controls;
- 10-second station recipes for Coal, Iron Ingot, Iron Armor, and Fence, owned by station simulation instead of direct player-inventory crafting;
- completed station craft outputs stay in station output slots until collected, while output overflow drops onto the ground;
- a first damageable Training Drone target that uses the same Multitool Cutter lock-on damage path as resources;
- Esc pause behavior with a small pause overlay and Resume action;
- mouse-based facing and cutter targeting direction;
- code-drawn placeholders with no graphic assets yet;
- shared prototype definitions for current items, resources, recipes, buildings, drops, durability, costs, stack sizes, display names, footprints, and station recipe durations through `DataRegistry`.

To run it: open `project.godot` in Godot 4.6.x stable and launch the main scene.

## Automated Smoke Test

Run the current headless gameplay smoke test with:

```sh
scripts/qa/run_pre_commit_smoke.sh
```

The smoke runner has a default 120-second timeout and fails if the run creates new untracked files or changes the tracked working tree diff.

Enable the versioned pre-commit hook once per clone:

```sh
git config core.hooksPath .githooks
```

## Current Architecture Review Status

The current prototype loop passes the headless smoke test, the P0 stability fixes are closed, and the first shared data registry is in place. The next major work should focus on the architecture backlog in [TODO.md](TODO.md): station-owned crafting, save/load-safe world generation, a single gameplay mode owner, real viewport UI input coverage, and replacing broader string/group contracts with explicit behavior contracts.
