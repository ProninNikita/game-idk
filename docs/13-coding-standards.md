# Стандарты кода и сцен

Статус: `Draft`

## Цель

Код должен помогать быстро прототипировать, но не превращать проект в набор не связанных сцен. Эти правила можно ослаблять для throwaway-прототипов, но gameplay systems и save/load должны писаться аккуратно сразу.

## GDScript

Правила:

- использовать типы для публичных полей, аргументов и return values;
- использовать `StringName` для id, action names и tags;
- избегать magic strings в gameplay logic;
- держать функции короткими, если они описывают разные уровни логики;
- не смешивать UI, data mutation и world simulation в одной функции;
- не использовать autoload как глобальную корзину.

Пример:

```gdscript
func can_accept_item(item_id: StringName, amount: int) -> bool:
    if amount <= 0:
        return false
    return _storage.has_space_for(item_id, amount)
```

## Именование

### Файлы

- Сцены: `player.tscn`, `furnace.tscn`, `inventory_panel.tscn`.
- Скрипты: `player_controller.gd`, `inventory_component.gd`.
- Resources: `item_wood.tres`, `recipe_ingot.tres`, `building_furnace.tres`.

### Classes

- `PlayerController`
- `InventoryComponent`
- `RecipeDef`
- `BuildingDef`
- `MachineScheduler`

### IDs

IDs пишутся в snake_case:

- `wood`
- `stone_axe`
- `cooked_food`
- `machine_collector`
- `recipe_iron_ingot`

## Сигналы

Сигналы использовать для событий между системами, но не для скрытой логики, которую трудно отследить.

Хорошо:

- inventory changed;
- machine state changed;
- player died;
- day phase changed;
- building placed.

Осторожно:

- сигнал, который запускает цепочку из 5 неочевидных действий;
- сигнал вместо обычного вызова внутри одного компонента;
- глобальный сигнал без payload contract.

Пример:

```gdscript
signal item_added(item_id: StringName, amount: int)
signal machine_state_changed(machine_id: int, state: MachineState)
```

## Сцены

Каждая сцена должна иметь понятную ответственность.

Плохо:

- `world.gd` управляет временем, UI, инвентарем, врагами, сохранением и крафтом.

Хорошо:

- `world.gd` координирует world-level systems;
- `inventory_component.gd` отвечает за предметы;
- `save_manager.gd` сериализует;
- `hud.gd` только отображает.

## Node groups

Groups использовать для широких категорий:

- `interactable`;
- `damageable`;
- `machines`;
- `buildings`;
- `resource_nodes`.

Не использовать groups как замену архитектуры. Если у объекта сложный contract, лучше компонент или интерфейсный метод.

## Error handling

Gameplay code должен падать громко в dev-сценариях и мягко в runtime.

Для данных:

- при загрузке registry проверять duplicate ids;
- проверять missing icons/scenes;
- проверять recipes на существующие item ids;
- логировать понятные ошибки.

Для save:

- не крашиться на corrupted save;
- показывать fallback message;
- держать backup save, если возможно.

## Debug tools

Разрешенные debug helpers:

- spawn item;
- toggle day/night;
- show grid;
- show machine states;
- show chunk boundaries;
- save/load hotkeys.

Перед demo build:

- debug shortcuts отключить или спрятать за dev flag;
- debug overlays не должны включаться случайно.

## Git discipline

Когда Git будет включен:

- один commit - один смысл;
- перед обновлением Godot делать commit;
- не смешивать art import churn и gameplay code без причины;
- не коммитить временные large files;
- не править import metadata вручную без необходимости.

## Comments

Комментарии нужны там, где решение не очевидно:

- почему формула такая;
- почему workaround нужен;
- почему порядок операций важен.

Не писать комментарии, которые пересказывают строку кода.

