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
- procedural placement of trees, stone, ore, and wild crops;
- a player with top-down movement;
- a starting pickaxe behavior that breaks nearby resources;
- destroyed resources drop items onto the ground;
- nearby ground items are picked up if the inventory has space;
- a slot-based inventory with a visible HUD panel;
- a visible 9-slot toolbelt with the starting pickaxe locked in slot 1;
- a full inventory window toggled with Tab or I;
- mouse-based facing and harvesting direction;
- code-drawn placeholders with no graphic assets yet.

To run it: open `project.godot` in Godot 4.6.x stable and launch the main scene.
