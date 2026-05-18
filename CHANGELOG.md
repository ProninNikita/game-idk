# Changelog

This file tracks version history, new features, balance changes, fixes, and technical decisions that matter to players or development.

The format is based on Keep a Changelog: https://keepachangelog.com/

## How to Maintain

- Add all new features to `Unreleased` first.
- When releasing a version, move entries from `Unreleased` into a new version block.
- Use `MAJOR.MINOR.PATCH` versioning.
- Prototype versions can use `0.x.y`.

## Change Types

- `Added` - new features, documents, content, or systems.
- `Changed` - changes to existing behavior, balance, or structure.
- `Fixed` - bug fixes.
- `Removed` - removed features, data, or documents.
- `Technical` - internal architecture, tooling, or pipeline changes.
- `Known Issues` - known issues for the version.

## [Unreleased]

### Added

- Version and change history document.
- Git-ready structure for the project start.
- Added `TODO.md` with a checklist for the first prototype: 150x150 map, resources, pickaxe, inventory, and first automation.
- README now links to `TODO.md`.
- Added the initial Godot project with `project.godot` and the main scene.
- Added a procedural 150x150 debug map.
- Added resource nodes: trees, stone, ore, and wild crops.
- Added a top-down player controller with a starting pickaxe and harvesting area.
- Added a simple unlimited inventory and HUD with resource counts.
- Added code-drawn placeholder visuals with no graphic assets, so they can be replaced by sprites later.

### Changed

- README and documentation index now link to the changelog.
- `Unreleased` includes planned work for manual harvesting of wood, stone, ore, and crops into the inventory.
- TODO updated to reflect the first completed prototype steps.

### Fixed

- Fixed Godot 4.6 issues where GDScript warnings about inferred Variant types stopped parsing as errors.
- Added input actions to `project.godot`, so movement and actions exist before runtime setup.

### Technical

- Added `.gitignore` for the Godot project.
- Added `scenes/` and `scripts/` structure for Godot.
- Map resources are spawned as separate interactive scenes, while the ground is drawn by one world node instead of creating 22,500 Node objects.
- Added the `ItemDef` Resource class for future item definitions.
- The project was migrated by the Godot 4.6.2 editor and now includes script `.gd.uid` files.

### Known Issues

- Godot 4.3 was detected locally earlier, while the recommended project version is Godot 4.6.x stable.
- On this machine, the old Godot path `/Applications/Godot.app/Contents/MacOS/Godot` is not valid, so runtime checks should use the current Godot install path.

## [0.1.0] - 2026-05-18

### Added

- Initial project documentation:
  - vision;
  - Game Design Document;
  - systems design;
  - Godot technical design;
  - data and balance;
  - world generation;
  - UI/UX;
  - art and audio;
  - production roadmap;
  - testing and release;
  - backlog;
  - decisions and risks;
  - coding standards;
  - content pipeline.
- Recorded the engine recommendation: Godot 4.6.x stable.
- Recorded the latest checked stable Godot version on May 18, 2026: Godot 4.6.2-stable.
- Recorded the previously detected local Godot version: 4.3.stable.official.

### Technical

- Created the base documentation file structure.
