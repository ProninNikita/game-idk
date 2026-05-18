# Decisions, Risks, and Questions

Status: `Draft`

## Decision Log

### ADR-0001: Top-Down 2D

Date: 2026-05-18

Decision: the game is designed as 2D top-down.

Reason:

- base and logistics are easier to read;
- faster prototyping;
- Godot 2D works well for tile/grid systems;
- lower art cost than full 3D.

Consequences:

- strong silhouettes and UI overlays are needed;
- world verticality is limited;
- large objects can hide the player, so fade/outline behavior is required.

### ADR-0002: Godot 4.6.x Stable

Date: 2026-05-18

Decision: start on Godot 4.6.x stable; the currently checked stable version is 4.6.2-stable.

Reason:

- a newer stable branch is better for a new project;
- beta/RC builds are not needed for MVP;
- local 4.3 was outdated compared with the checked stable version.

Consequences:

- update local Godot before regular development;
- run a smoke test after any 4.6.x update.

### ADR-0003: GDScript First

Date: 2026-05-18

Decision: write the first prototype in GDScript.

Reason:

- fast iteration;
- strong integration with the Godot editor;
- less setup friction.

Consequences:

- typing and boundaries must stay disciplined;
- heavy simulations can be optimized or moved later if needed.

### ADR-0004: Grid-Based Automation

Date: 2026-05-18

Decision: building and automation are built around a grid.

Reason:

- clear placement;
- readable logistics;
- simpler save/load;
- simpler building placement.

Consequences:

- player movement can be free, but buildings live on the grid;
- coordinate conversion must be consistent.

## Main Risks

### Risk: Scope Too Wide

Probability: high.

Impact: high.

Mitigation:

- keep MVP narrow;
- build each system through a playable vertical path;
- do not add biomes/resources before the first automated chain works.

### Risk: Survival Gets in the Way of Automation

Probability: medium.

Impact: high.

Mitigation:

- survival pressure should be periodic and plannable;
- early hunger/night systems should not constantly interrupt building;
- automation should solve survival problems.

### Risk: Automation Becomes Boring Because Chains Are Too Simple

Probability: medium.

Impact: high.

Mitigation:

- add bottlenecks: fuel, space, output blocking, power;
- create new problems after automation;
- make diagnostics clear.

### Risk: Performance With Many Machines

Probability: medium.

Impact: medium/high.

Mitigation:

- do not use per-machine `_process` as the final solution;
- batch simulation ticks;
- profile before content scale-up.

### Risk: Procedural World Is Not Interesting

Probability: medium.

Impact: high.

Mitigation:

- start with a handcrafted test map;
- add POI rules;
- every biome must have a gameplay role.

## Open Questions

- What is the final title?
- What exact visual style: pixel art or hand-painted low-res?
- Will the main character have character progression, or only tool/base progression?
- How harsh should death be?
- Is food spoilage needed?
- Which energy model is best: radius, wires, or hybrid?
- Should threats attack machines or only the player?
- What is the world's final goal?
- Is a story layer needed, or is environmental storytelling enough?
- Is the map infinite or large but finite?

## Decisions for the Next Prototype

- Map: handcrafted test map.
- Survival: hunger + night threat.
- Automation: collector + conveyor + furnace.
- Build grid: yes.
- Energy: fuel-only for now, no network.
- Save/load: required by the end of M3.
