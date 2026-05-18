# Documentation Index

This documentation set keeps the project from drifting into chaos: it should make it quick to check current decisions, understand why a system exists, and preserve context between prototypes.

## Main Documents

| File | Purpose |
| --- | --- |
| [00-version-and-tools.md](00-version-and-tools.md) | Godot version, local environment, and engine update rules. |
| [01-vision.md](01-vision.md) | Short vision, pillars, audience, and project boundaries. |
| [02-game-design-document.md](02-game-design-document.md) | Main GDD: loops, progression, world, and player actions. |
| [03-systems-design.md](03-systems-design.md) | Survival, automation, crafting, threats, and ecology details. |
| [04-technical-design.md](04-technical-design.md) | Godot project architecture, scenes, autoloads, saves, and performance. |
| [05-data-balance.md](05-data-balance.md) | Data, tables, formulas, and balance knobs. |
| [06-world-generation.md](06-world-generation.md) | Biomes, chunks, generation, and persistent world changes. |
| [07-ui-ux.md](07-ui-ux.md) | Controls, HUD, inventory, building, and accessibility. |
| [08-art-audio.md](08-art-audio.md) | Visual style, camera, animation, sound, and music. |
| [09-production-roadmap.md](09-production-roadmap.md) | MVP, vertical slice, alpha, beta, and readiness criteria. |
| [10-testing-release.md](10-testing-release.md) | Testing, checklists, performance, and release discipline. |
| [11-backlog.md](11-backlog.md) | Epics and starting tasks. |
| [12-decisions-and-risks.md](12-decisions-and-risks.md) | Decision log, risks, and open questions. |
| [13-coding-standards.md](13-coding-standards.md) | GDScript style, scenes, signals, and code structure. |
| [14-content-pipeline.md](14-content-pipeline.md) | How to add items, recipes, buildings, biomes, and assets. |
| [TODO.md](../TODO.md) | Current prototype task checklist. |
| [CHANGELOG.md](../CHANGELOG.md) | Version history, new features, changes, and fixes. |

## How to Use

1. Before developing a new system, update the relevant design document.
2. After implementation, mark completed work in [11-backlog.md](11-backlog.md).
3. If an architecture decision is made, add an entry to [12-decisions-and-risks.md](12-decisions-and-risks.md).
4. If balance changes by more than 20-30%, record the reason in [05-data-balance.md](05-data-balance.md).
5. If a new content type is added and the current process is not enough, update [14-content-pipeline.md](14-content-pipeline.md).
6. Record all new features and notable changes in [CHANGELOG.md](../CHANGELOG.md) under `Unreleased`.

## Document Statuses

- `Draft`: early version, can be changed freely.
- `Prototype`: being tested in a prototype.
- `Locked for milestone`: fixed until the end of the current milestone.
- `Deprecated`: no longer used.
