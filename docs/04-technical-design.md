# Технический дизайн Godot

Статус: `Draft`

## Цель архитектуры

Сделать Godot-проект, который быстро дает playable prototype, но не рушится при добавлении автоматизации, сохранений и генерации мира.

## Главные технические решения

- Движок: Godot 4.6.x stable.
- Измерение мира: grid/tile-based логика поверх 2D top-down.
- Игровые сущности: сцены Godot + data resources.
- Данные: typed GDScript Resources для items/recipes/buildings.
- Сохранения: versioned save data, не сериализовать напрямую живое дерево сцен без контроля.
- Симуляция: разделить visual update и logic tick.

## Предлагаемая структура проекта

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

## Autoload singletons

Использовать умеренно. Autoload хорош для сервисов, но плох как свалка состояния.

Предлагаемые autoload:

- `Game`: управляет состоянием приложения, сменой сцен, pause.
- `SaveManager`: save/load, миграции.
- `DataRegistry`: доступ к item/recipe/building definitions.
- `EventBus`: глобальные сигналы только для cross-system событий.
- `Settings`: настройки, input remap, audio volumes.

Не хранить в autoload:

- живые entity instance;
- весь world state;
- временную combat-логику;
- UI-состояние конкретного экрана.

## Scene ownership

### Main scene

Отвечает за:

- загрузку текущего мира;
- создание player;
- подключение UI;
- routing pause/save.

### World scene

Отвечает за:

- tilemap/chunks;
- spawner;
- building grid;
- world tick;
- chunk persistence.

### Player scene

Отвечает за:

- движение;
- interaction ray/area;
- inventory component;
- health/survival stats;
- animation state.

### Building/Machine scenes

Каждая машина:

- имеет data definition;
- имеет координату grid;
- имеет input/output slots;
- имеет tick method или подписку на simulation scheduler;
- умеет export/import save state.

## Компоненты

Предлагаемые компоненты:

- `HealthComponent`;
- `InventoryComponent`;
- `InteractableComponent`;
- `FuelComponent`;
- `EnergyConsumerComponent`;
- `CraftingComponent`;
- `StorageComponent`;
- `GridOccupantComponent`.

Компоненты должны быть простыми Nodes или Resources. Не делать ECS на старте, если Godot-сцены закрывают задачу.

## Grid и координаты

Нужно единое правило:

- world position: пиксели/units Godot;
- grid position: `Vector2i`;
- chunk position: `Vector2i`;
- tile position inside chunk: `Vector2i`.

Все здания должны хранить grid coordinate, а не только world transform.

## Simulation tick

Не завязывать производство на `_process(delta)` каждой машины, если машин станет много.

Рекомендация:

- MVP: машины могут тикать в `_physics_process`, но через общий `MachineScheduler`.
- После MVP: фиксированный simulation tick, например 5-10 раз в секунду для production logic.
- Visual animation отдельно от production tick.

## Items

Item definition как Resource:

```gdscript
class_name ItemDef
extends Resource

@export var id: StringName
@export var display_name: String
@export var stack_size: int = 99
@export var tags: Array[StringName] = []
@export var icon: Texture2D
```

Item stack в runtime:

```gdscript
class_name ItemStack

var item_id: StringName
var amount: int
```

## Recipes

Recipe definition как Resource:

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

Для реального кода позже лучше заменить raw Dictionary на typed helper structures, если потребуется editor usability.

## Buildings

Building definition:

- id;
- scene path;
- size in grid cells;
- build cost;
- tags;
- max health;
- energy use/produce;
- allowed rotations;
- collision layer;
- footprint rules.

## Save/load

Сохранять:

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

Не сохранять напрямую:

- Node paths как единственный идентификатор;
- runtime object references;
- transient animation state;
- данные, которые можно восстановить из definitions.

## Save migration

Каждый save содержит `schema_version`.

При изменении формата:

1. загрузить старую структуру;
2. применить миграции по порядку;
3. сохранить в новом формате после успешной загрузки;
4. держать тестовый save для каждого важного milestone.

## Производительность

Риски:

- много машин с `_process`;
- много physics bodies;
- pathfinding для множества существ;
- частая пересборка TileMap;
- сохранение больших чанков целиком.

Правила:

- чанки сохранять diff-ами, если world generation deterministic;
- симуляцию машин batching-ом;
- избегать per-frame allocation в hot paths;
- UI обновлять по событиям, а не каждый кадр;
- профилировать до крупных оптимизаций.

## Тестируемость

Логику рецептов, инвентаря, стаков, сохранений и генерации держать в классах, которые можно тестировать без запуска полной сцены.

Минимальные тестируемые модули:

- inventory add/remove/split/merge;
- recipe validation;
- building placement;
- save serialization;
- deterministic world generation.

