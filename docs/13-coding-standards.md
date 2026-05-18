# Code and Scene Standards

Status: `Draft`

## Goal

Code should support fast prototyping without turning the project into unrelated scenes. These rules can be relaxed for throwaway prototypes, but gameplay systems and save/load should be written carefully from the start.

## GDScript

Rules:

- use types for public fields, arguments, and return values;
- use `StringName` for ids, action names, and tags;
- avoid magic strings in gameplay logic;
- keep functions short when they describe different logic levels;
- do not mix UI, data mutation, and world simulation in one function;
- do not use autoloads as a global junk drawer.

Example:

```gdscript
func can_accept_item(item_id: StringName, amount: int) -> bool:
    if amount <= 0:
        return false
    return _storage.has_space_for(item_id, amount)
```

## Naming

### Files

- Scenes: `player.tscn`, `furnace.tscn`, `inventory_panel.tscn`.
- Scripts: `player_controller.gd`, `inventory_component.gd`.
- Resources: `item_wood.tres`, `recipe_ingot.tres`, `building_furnace.tres`.

### Classes

- `PlayerController`
- `InventoryComponent`
- `RecipeDef`
- `BuildingDef`
- `MachineScheduler`

### IDs

IDs use snake_case:

- `wood`
- `stone_axe`
- `cooked_food`
- `machine_collector`
- `recipe_iron_ingot`

## Signals

Use signals for events between systems, but not for hidden logic that becomes hard to trace.

Good:

- inventory changed;
- machine state changed;
- player died;
- day phase changed;
- building placed.

Use carefully:

- a signal that starts a chain of five non-obvious actions;
- a signal replacing a normal call inside one component;
- a global signal without a payload contract.

Example:

```gdscript
signal item_added(item_id: StringName, amount: int)
signal machine_state_changed(machine_id: int, state: MachineState)
```

## Scenes

Each scene should have a clear responsibility.

Bad:

- `world.gd` controls time, UI, inventory, enemies, saving, and crafting.

Good:

- `world.gd` coordinates world-level systems;
- `inventory_component.gd` handles items;
- `save_manager.gd` serializes;
- `hud.gd` only displays.

## Node Groups

Use groups for broad categories:

- `interactable`;
- `damageable`;
- `machines`;
- `buildings`;
- `resource_nodes`.

Do not use groups as a replacement for architecture. If an object has a complex contract, use a component or interface-style method.

## Error Handling

Gameplay code should fail loudly in development scenarios and gracefully at runtime.

For data:

- check duplicate ids when loading the registry;
- check missing icons/scenes;
- validate recipes against existing item ids;
- log clear errors.

For saves:

- do not crash on corrupted saves;
- show a fallback message;
- keep backup saves where possible.

## Debug Tools

Allowed debug helpers:

- spawn item;
- toggle day/night;
- show grid;
- show machine states;
- show chunk boundaries;
- save/load hotkeys.

Before a demo build:

- disable debug shortcuts or hide them behind a dev flag;
- debug overlays should not turn on accidentally.

## Git Discipline

Once Git is enabled:

- one commit, one meaning;
- commit before updating Godot;
- do not mix art import churn and gameplay code without reason;
- do not commit temporary large files;
- do not edit import metadata manually unless needed.

## Comments

Comments are useful when a decision is not obvious:

- why a formula has this shape;
- why a workaround is needed;
- why operation order matters.

Do not write comments that only repeat the line of code.
