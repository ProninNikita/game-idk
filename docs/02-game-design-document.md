# Game Design Document

Status: `Draft`

## Overview

Project Hearthline is a 2D top-down game about survival, crafting, base building, and automation. The player explores the world, gathers resources, builds a camp, creates production chains, and survives pressure from the environment.

## Core Loop

1. Explore nearby territory.
2. Find a resource or threat.
3. Gather, mine, avoid, or fight.
4. Process resources manually or through a building.
5. Build a base improvement.
6. Automate a repeated action.
7. Prepare for the next environmental pressure.
8. Expand into a new biome or deeper into the current one.

## Moment-to-Moment Loop

- move;
- gather;
- chop/mine/break;
- pick up;
- craft;
- place buildings;
- carry items;
- check character state;
- react to threats;
- return to base.

## Mid-Term Loop

- discover a new resource;
- build a new chain;
- stabilize food/energy/defense;
- upgrade tools;
- expand storage;
- unlock a new biome;
- survive an event.

## Long-Term Loop

- turn the base into a resilient autonomous system;
- unlock all major technologies;
- build infrastructure for distant biomes;
- survive seasonal or world-scale crises;
- reach the world's final objective.

## Session Rhythm

Expected rhythm:

- 5 minutes: a small goal, such as gathering wood, placing a campfire, or starting a furnace.
- 20 minutes: a progression chain, such as stabilizing food or automating planks.
- 60 minutes: a milestone, such as unlocking a new biome or building a defensive perimeter.

## Game Start

The player survives a crash landing in a small escape capsule. The capsule's usable supplies are nearly gone; the one reliable tool is a **Multitool Cutter** that can cut resources, assist construction, and later damage simple threats through a lock-on beam.

The player appears in a relatively safe area:

- basic wood/stone/food are nearby;
- the escape capsule gives a clear starting landmark;
- the Multitool Cutter teaches gathering, building, and future defense through one consistent interaction;
- night danger exists, but the first night should be survivable;
- 1-2 interesting points are visible nearby;
- the first screen should show direction: resources, base space, and the edge of danger.

## Player Actions

### Movement

- WASD/left stick.
- Diagonal movement is normalized.
- Camera follows the player with light smoothing.

### Gathering

- Manual gathering is quick and tactile.
- The Multitool Cutter locks onto a nearby target and deals gradual damage while the lock is valid.
- Tools affect speed, yield, and resource access.
- Some resources require stations or automation.

### Crafting

- Fast manual crafting for basic items.
- Stations for advanced recipes.
- Production buildings use the same recipes or automated variants.

### Building

- Grid-based placement.
- Building preview shows whether the position is valid.
- Buildings can rotate if they have input/output direction.
- Dismantling returns part of the resources; full refund is acceptable in early prototype for convenience.

### Combat and Defense

- Combat should not be the main genre, but it should create pressure.
- Emphasis is on preparation: light, walls, traps, turrets, or repellents.
- Manual combat is simple: attack, possible dodge/dash later, ranged weapons after MVP.

## Resources

Starting resources:

- wood;
- stone;
- fiber;
- berries or raw_food;
- ore;
- coal or fuel;
- water.

Intermediate resources:

- planks;
- bricks;
- ingots;
- cooked_food;
- gears;
- wire;
- machine_parts.

Abstract resources:

- energy;
- heat;
- light;
- research_points.

## Progression

### Tier 0: Hand Survival

- food gathering;
- campfire;
- basic tools;
- manual crafting;
- first chest.

### Tier 1: Stable Camp

- workbench;
- furnace;
- farm/food dryer;
- walls or light;
- simple processing.

### Tier 2: First Automation

- resource collector;
- conveyor/transporter;
- automatic furnace;
- storage node;
- energy generator.

### Tier 3: Resilient Base

- automated food;
- power network;
- defensive perimeter;
- waste/byproduct processing;
- expedition stations.

### Tier 4: World and Final Goal

- deep biomes;
- rare materials;
- complex chains;
- global event or final construction.

## Technologies

Research unlocks through:

- processing new resources;
- building a research station;
- completing systemic goals;
- studying artifacts/anomalies.

Important: the tech tree should not become a menu disconnected from the world. The best unlocks should be tied to player actions.

## Day and Night

Day:

- gathering;
- construction;
- distant trips;
- chain setup.

Night:

- increased danger;
- importance of light/heat;
- activity from certain creatures or events;
- useful time for processing and planning if the base is ready.

## Death and Failure

Prototype options:

- the player loses some items and respawns at the base;
- the world continues living;
- items can be recovered from the death location;
- the base should not instantly collapse from one mistake.

Permadeath is not recommended for the first mode. It can become a separate hardcore mode later.

## Victory

The final goal is still open. Possible directions:

- build a beacon/machine that stabilizes the world;
- survive a full seasonal cycle;
- reach the center of the world;
- restore an ancient network that changes biome rules.

MVP does not need a final victory. It needs a clear vertical slice goal: build a stable base and survive the third night or first event.
