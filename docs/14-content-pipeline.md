# Content Pipeline

Status: `Draft`

## Goal

Adding new content should be repeatable: items, recipes, buildings, machines, and biomes follow the same path from idea to playable verification.

## General Process

1. Describe the content's design role.
2. Add the data definition.
3. Add placeholder visual/audio if needed.
4. Connect it to the registry.
5. Add a recipe or unlock condition.
6. Test it on the test map.
7. Record balance notes.

If content does not change a player decision, it is not an MVP priority.

## Adding an Item

Checklist:

- [ ] Has `id`.
- [ ] Has display name.
- [ ] Has category/tags.
- [ ] Has stack size.
- [ ] Has icon.
- [ ] Has source: where the item comes from.
- [ ] Has sink: where the item is spent.
- [ ] Item is tested in inventory.

Example:

```text
id: iron_ore
category: raw
tags: ore, smeltable
stack_size: 50
source: rocky_field nodes, collector
sink: furnace -> iron_ingot
```

## Adding a Recipe

Checklist:

- [ ] All input items exist.
- [ ] All output items exist.
- [ ] Craft time is set.
- [ ] Station type is set.
- [ ] Unlock condition is set or explicitly `none`.
- [ ] Recipe does not break progression gates.
- [ ] Recipe is tested manually and at a station.

Balance questions:

- What was the player doing before this recipe?
- What does the recipe now make easier?
- What new problem appears after unlocking it?

## Adding a Building

Checklist:

- [ ] Building definition.
- [ ] Scene.
- [ ] Footprint.
- [ ] Build cost.
- [ ] Placement rules.
- [ ] Collision.
- [ ] Save/load state.
- [ ] Destroy/remove behavior.
- [ ] UI/status feedback.

For machines additionally:

- [ ] Input slots.
- [ ] Output slots.
- [ ] Processing state.
- [ ] Blocked state.
- [ ] Fuel/energy requirement, if any.
- [ ] Tick behavior.

## Adding a Biome

Checklist:

- [ ] Gameplay role.
- [ ] Terrain tiles.
- [ ] Resource distribution.
- [ ] Threat profile.
- [ ] Unique reward.
- [ ] Traversal rule, if any.
- [ ] Audio/ambience.
- [ ] Map color/marker.

A biome should answer at least one question:

- Why does the player go here?
- Why is this place dangerous or inconvenient?
- What can be done here that cannot be done in the starting area?

## Adding a Threat

Checklist:

- [ ] Purpose.
- [ ] Spawn rule.
- [ ] Telegraph.
- [ ] Attack/pressure.
- [ ] Counterplay.
- [ ] Reward or relief after dealing with it.
- [ ] Save/load relevance.

A threat without counterplay is frustrating. A threat without telegraphing feels unfair.

## Placeholder Policy

Placeholder content is acceptable if:

- it clearly lives in `prototype`;
- it is easy to replace;
- it does not hide gameplay readability problems.

Placeholder content is dangerous if:

- all items look the same;
- a machine does not show direction;
- a threat is not readable;
- UI is built around temporary art.

## Content Tables

At the start, data can live in Godot Resources. If balance changes often, add CSV export/import.

Possible tables:

- items;
- recipes;
- buildings;
- machines;
- biomes;
- threats;
- tech unlocks.

## Definition of Done for New Content

Content is considered added when:

- it can be obtained in game;
- it can be used in game;
- it saves/loads if it remains in the world;
- it has readable placeholder/final visual;
- it is mentioned in the relevant design or balance document;
- it does not create red errors in Output.
