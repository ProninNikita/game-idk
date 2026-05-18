# Production Roadmap

Status: `Draft`

## Principle

Playable prototype first, vertical slice second, expansion after that. Do not build dozens of systems before the core loop is tested.

## Phase 0: Project Setup

Goal: working Godot environment and documentation baseline.

Done:

- target Godot chosen;
- documentation created;
- MVP scope defined.

Next:

- update local Godot to 4.6.x stable;
- create Godot project;
- set up Git;
- create base folder structure;
- add placeholder assets.

## Phase 1: Movement and Interaction Prototype

Goal: the player moves well and interacts with the world.

Scope:

- player movement;
- Camera2D follow;
- basic input map;
- resource nodes;
- hit/gather resources;
- inventory backend;
- simple HUD;
- placeholder map.

Exit criteria:

- wood/stone/food can be gathered;
- items enter inventory;
- the player understands selected tool/action;
- controls feel acceptable.

## Phase 2: Survival Prototype

Goal: the world starts pressuring the player.

Scope:

- hunger;
- health;
- day/night cycle;
- campfire;
- simple food/cooking;
- first night threat;
- death/respawn loop.

Exit criteria:

- the first night creates tension;
- the player understands how to prepare;
- hunger makes food matter without annoying the player every minute.

## Phase 3: Building and Crafting Prototype

Goal: the player builds a base.

Scope:

- build mode;
- ghost placement;
- workbench;
- furnace;
- chest;
- recipes;
- simple building save state.

Exit criteria:

- a small camp can be built;
- crafting and building use the same item definitions;
- buildings save and load.

## Phase 4: Automation Prototype

Goal: the first production chain works without player involvement.

Scope:

- collector;
- conveyor;
- inserter/arm;
- furnace automation;
- machine states;
- blocked output handling;
- visible status icons.

Exit criteria:

- at least one chain can be automated;
- machine stoppages are visually understandable;
- simulation is not tied to chaotic per-node logic.

## Phase 5: Vertical Slice

Goal: 30-60 minutes of coherent gameplay.

Scope:

- small generated/handcrafted world;
- 3-4 biomes/zones;
- tech progression to Tier 2;
- first event;
- base defense;
- save/load;
- audio/VFX pass;
- UI polish pass.

Exit criteria:

- a new player understands the first goals;
- there are 3-5 meaningful decisions;
- the player can lose because of poor preparation;
- recovery after mistakes is possible;
- there is a reason to expand the base.

## Phase 6: Alpha

Goal: all core systems exist, content can still be rough.

Scope:

- chunk generation;
- multiple biomes;
- broader tech tree;
- advanced logistics;
- more threats/events;
- balance pass;
- performance pass.

Exit criteria:

- the game supports several hours of progression;
- save format is stable;
- major systems are not being rewritten every week.

## Phase 7: Beta

Goal: stabilization and content.

Scope:

- bug fixing;
- UX polish;
- tutorial/onboarding;
- final art/audio pass;
- localization prep;
- Steam page assets if needed;
- demo build.

Exit criteria:

- known critical bugs are closed;
- performance targets are met;
- tutorial does not break;
- playtesters understand the game loop.

## Milestone Naming

- M0 Docs and setup.
- M1 Hands in the dirt.
- M2 First night.
- M3 First base.
- M4 First machine.
- M5 Vertical slice.

## Weekly Rhythm

- Monday: choose 3-5 tasks for the week.
- Midweek: short playable check.
- End of week: build + notes + backlog cleanup.

Even a solo project benefits from an end-of-week build. It shows the real state, not the mood.
