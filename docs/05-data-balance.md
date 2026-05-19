# Data and Balance

Status: `Draft`

## Goal

Balance should support three feelings:

- manual labor quickly becomes a clear problem;
- automation gives noticeable relief;
- survival does not disappear completely, but shifts into planning.

## Base Units

- Time: real-time seconds.
- Distance: grid cells.
- Day: start with 12-18 real-time minutes, then verify through playtests.
- Night: 4-6 real-time minutes.
- Stack: 20/50/99 depending on item type.

## Item Categories

| Category | Examples | Stack | Notes |
| --- | --- | --- | --- |
| Raw | wood, stone, ore, fiber | 50-99 | Frequent gathering, high logistics volume. |
| Food | berries, cooked_food | 10-20 | Can spoil later. |
| Fuel | coal, charcoal, resin | 50 | Used by heat/energy. |
| Processed | plank, brick, ingot | 50 | Construction backbone. |
| Components | gear, wire, machine_part | 20-50 | Progression bottlenecks. |
| Rare | crystal, ancient_core | 5-20 | Biome goals. |

## Starting Recipes

| Recipe | Input | Output | Time | Station |
| --- | --- | --- | --- | --- |
| planks | 2 wood | 1 plank | 1.0s | hand/workbench |
| campfire | 5 wood, 3 stone | 1 campfire | 2.0s | hand |
| stone_axe | 2 stone, 1 wood, 1 fiber | 1 stone_axe | 2.0s | hand |
| furnace | 10 stone, 4 clay/brick | 1 furnace | 4.0s | workbench |
| ingot | 2 ore, 1 fuel | 1 ingot | 5.0s | furnace |
| collector | 6 planks, 4 ingots, 2 gears | 1 collector | 8.0s | workbench |
| conveyor | 1 plank, 1 gear | 2 conveyors | 2.0s | workbench |

All numbers are starting values. Their job is to create a playable rhythm, not final balance.

## Hunger Balance

Parameters:

- `hunger_max`;
- `hunger_decay_idle`;
- `hunger_decay_working`;
- `food_restore`;
- `starvation_damage_rate`.

Starting goal:

- the player can survive the first day on found food;
- by the third day, the player needs farming, cooking, or a stable food route;
- cooked food should be 2-3 times more valuable than raw food.

## Resource Balance

### Wood

Role:

- first resource;
- fuel;
- construction;
- early logistics.

Risk: if wood is too universal, the player will chop the same thing forever. Add stone/ore/fiber constraints early.

### Stone

Role:

- furnaces;
- walls;
- basic machines;
- roads/foundation later.

### Ore

Role:

- first automation gate;
- requires an expedition or mine;
- processing requires fuel.

### Food

Role:

- survival pressure;
- reason to build farms/cooking/storage;
- expedition resource.

## Automation Formula

A good machine should pay for itself not immediately, but soon enough to feel worthwhile.

Example:

- manual wood gathering: 1 wood / 1.5s;
- collector: 1 wood / 5s, but without player attention;
- collector cost: 6 planks + 4 ingots + 2 gears;
- attention payback: 5-10 minutes after construction.

Balance output/sec and player attention/sec, not only raw throughput.

## Technology Gates

| Gate | Requires | Unlocks |
| --- | --- | --- |
| Fire | wood + stone | night, cooking, heat |
| Workbench | planks + fiber | tools, stations |
| Smelting | stone + fuel + ore | ingots |
| Mechanics | ingots + gears | collector/conveyor |
| Power | fuel + machine parts | powered machines |
| Farming | water + seeds | stable food |
| Defense | stone + light + energy | night safety |

## Current Prototype Recipes

| Station | Input | Output | Time |
| --- | --- | --- | --- |
| Furnace | 2 wood | 1 coal | 10s |
| Furnace | 1 ore + 1 coal | 1 iron ingot | 10s |
| Forge | 10 iron ingots | 1 iron armor | 10s |
| Workbench | 5 wood | 1 fence | 10s |

The current fence item is a build token for a 1x1 fence building.

## Exploration Balance

Rule: a new biome should provide at least one of three things:

- a new resource;
- a new risk;
- a new way to solve an old problem.

If a biome only adds decoration, it is not needed in the first production scope.

## Time Economy

The game should reduce boredom through automation, not by simply speeding everything up.

Check questions:

- Which actions does the player repeat too often?
- Can that action be automated?
- Does the automation require a new decision, or is it simply bought?
- Does a new problem appear after automation?

## Playtest Metrics

Record during playtests:

- time to first campfire;
- time to first furnace;
- time to first collector;
- time to first automated chain;
- number of deaths before the third night;
- inventory opens per minute;
- where players drop items on the ground;
- which resources become bottlenecks.
