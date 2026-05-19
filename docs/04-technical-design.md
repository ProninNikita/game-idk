# Godot Technical Design

Status: `Draft`

## Architecture Goal

Build a Godot project that reaches a playable prototype quickly, but does not collapse when automation, saves, and world generation are added.

## Main Technical Decisions

- Engine: Godot 4.6.x stable.
- World measurement: grid/tile-based logic over 2D top-down space.
- Game entities: Godot scenes plus data resources.
- Data: typed GDScript Resources for items/recipes/buildings.
- Saves: versioned save data; do not serialize the live scene tree directly without control.
- Simulation: separate visual update from logic tick.

## Proposed Project Structure

```text
res://
  project.godot
  scenes/
    main/
    player/
    world/
    buildings/
    machines/
    ui/
  scripts/
    core/
    player/
    world/
    buildings/
    machines/
    ui/
    save/
  data/
    items/
    recipes/
    buildings/
    biomes/
    tech/
  art/
    sprites/
    tilesets/
    vfx/
    ui/
  audio/
    music/
    sfx/
  tests/
```

## Autoload Singletons

Use them sparingly. Autoloads are good for services, but bad as a dump for all state.

Proposed autoloads:

- `Game`: application state, scene switching, pause.
- `SaveManager`: save/load and migrations.
- `DataRegistry`: access to item/recipe/building definitions.
- `EventBus`: global signals only for cross-system events.
- `Settings`: settings, input remap, audio volumes.

Do not store in autoloads:

- live entity instances;
- all world state;
- temporary combat logic;
- UI state for a specific screen.

## Scene Ownership

### Main Scene

Responsible for:

- loading the current world;
- creating the player;
- connecting UI;
- routing pause/save.

### World Scene

Responsible for:

- tilemap/chunks;
- spawner;
- building grid;
- world tick;
- chunk persistence.

### Player Scene

Responsible for:

- movement;
- interaction ray/area;
- inventory component;
- health/survival stats;
- animation state.

### Building/Machine Scenes

Each machine:

- has a data definition;
- has a grid coordinate;
- has input/output slots;
- has a tick method or subscribes to a simulation scheduler;
- can export/import save state.

## Components

Proposed components:

- `HealthComponent`;
- `InventoryComponent`;
- `InteractableComponent`;
- `FuelComponent`;
- `EnergyConsumerComponent`;
- `CraftingComponent`;
- `StorageComponent`;
- `GridOccupantComponent`.

Components should be simple Nodes or Resources. Do not build an ECS at the start if Godot scenes solve the problem.

## Grid and Coordinates

Use one clear rule:

- world position: Godot pixels/units;
- grid position: `Vector2i`;
- chunk position: `Vector2i`;
- tile position inside chunk: `Vector2i`.

All buildings should store grid coordinates, not only world transforms.

## Simulation Tick

Do not bind production to `_process(delta)` on every machine if there will be many machines.

Recommendation:

- MVP: machines can tick in `_physics_process`, but through a shared `MachineScheduler`.
- After MVP: fixed simulation tick, for example 5-10 times per second for production logic.
- Visual animation stays separate from production tick.

## Items

Item definition as Resource:

```gdscript
class_name ItemDef
extends Resource

@export var id: StringName
@export var display_name: String
@export var stack_size: int = 99
@export var tags: Array[StringName] = []
@export var icon: Texture2D
```

Runtime item stack:

```gdscript
class_name ItemStack

var item_id: StringName
var amount: int
```

## Recipes

Recipe definition as Resource:

```gdscript
class_name RecipeDef
extends Resource

@export var id: StringName
@export var inputs: Dictionary
@export var outputs: Dictionary
@export var craft_time: float
@export var station_tags: Array[StringName]
@export var required_tech: StringName
```

In real code, raw Dictionary can later be replaced by typed helper structures if editor usability requires it.

## Buildings

Building definition:

- id;
- scene path;
- size in grid cells;
- build cost;
- tags;
- max health;
- energy use/production;
- allowed rotations;
- collision layer;
- footprint rules.

Current prototype buildings:

- `furnace`: 2x2 footprint, costs 2 stone and 1 wood.
- `forge`: 2x2 footprint, costs 4 stone and 2 ore.
- `workbench`: 2x2 footprint, costs 2 wood and 1 stone.
- `fence`: 1x1 footprint, costs 1 fence item.

Current prototype station behavior:

- interact with stations by pointing at a nearby station and pressing E;
- each active station can run one 10-second craft at a time;
- ingredients are removed from the player inventory when crafting starts;
- outputs are sent to the player inventory when crafting completes, with overflow dropped near the station;
- station recipes currently live in `building_instance.gd` and should move into data resources once item definitions mature.

## Save/Load

Save:

- game version;
- save schema version;
- world seed;
- day/time;
- player position/stats/inventory;
- discovered map;
- changed tiles;
- buildings list;
- machine states;
- loose items;
- active events.

Do not save directly:

- NodePaths as the only identifier;
- runtime object references;
- transient animation state;
- data that can be restored from definitions.

## Save Migration

Each save contains `schema_version`.

When the format changes:

1. load the old structure;
2. apply migrations in order;
3. save in the new format after a successful load;
4. keep a test save for each important milestone.

## Performance

Risks:

- many machines with `_process`;
- many physics bodies;
- pathfinding for many creatures;
- frequent TileMap rebuilds;
- saving large chunks whole.

Rules:

- save chunks as diffs if world generation is deterministic;
- batch machine simulation;
- avoid per-frame allocation in hot paths;
- update UI by events, not every frame;
- profile before major optimization.

## Testability

Keep recipe, inventory, stack, save, and generation logic in classes that can be tested without launching a full scene.

Minimum testable modules:

- inventory add/remove/split/merge;
- recipe validation;
- building placement;
- save serialization;
- deterministic world generation.
