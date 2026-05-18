# Генерация мира

Статус: `Draft`

## Цель

Мир должен поддерживать exploration, survival и automation. Он не обязан быть бесконечным на старте, но должен казаться достаточно большим, чтобы база и экспедиции имели смысл.

## Подход MVP

Рекомендация: сделать deterministic seed + chunk-based generation.

- Seed задает базовый мир.
- Chunks генерируются при входе в радиус.
- Изменения игрока сохраняются как diff.
- Важные точки создаются генератором, но могут быть размещены rules-based.

Для самого первого прототипа допустима handcrafted test map, но сразу проектировать API так, будто мир станет chunked.

## Размеры

Стартовые числа:

- tile size: 16 или 32 px, выбрать после art test;
- building grid: 1 tile или 2x2 tile footprint в зависимости от визуального масштаба;
- chunk size: 32x32 или 64x64 tiles;
- safe start radius: 2-3 chunks.

## Слои мира

- ground terrain;
- biome overlay;
- obstacles/resources;
- water/shore;
- buildings;
- loose items;
- light/heat influence;
- navigation/collision.

## Биомы MVP

### Meadow/Start

Роль:

- безопасный старт;
- wood, berries, fiber, stone;
- низкая угроза.

### Forest

Роль:

- много wood/fiber;
- хуже видимость;
- ночные угрозы сильнее;
- seed/plant resources.

### Rocky Field

Роль:

- stone/ore;
- меньше еды;
- больше открытого пространства для outpost.

### Wetland или River Edge

Роль:

- water;
- farming gate;
- slower movement;
- особые растения.

После MVP можно добавить desert, snow, ruins, fungal caves, ashland.

## Распределение ресурсов

Правила:

- стартовая зона содержит все для Tier 0;
- ore не должно быть слишком далеко для первой печи;
- редкие ресурсы должны требовать экспедиции;
- биомы должны создавать tradeoff, а не просто быть скином.

## Points of Interest

POI дают цели:

- abandoned camp;
- broken machine;
- old shrine/research point;
- rich ore node;
- safe cave entrance;
- strange growth;
- ruined power relay.

POI должны быть читаемы издалека через силуэт, свет, цвет или звук.

## Генерация дорог/маршрутов

На старте можно без дорог. Но если карта большая, полезны естественные маршруты:

- тропы через лес;
- берега рек;
- проходы между скалами;
- просеки к POI.

Игрок должен уметь строить собственные дороги позже, чтобы база физически меняла мир.

## Навигация существ

MVP:

- простое движение к игроку/цели;
- избегание непроходимых tile;
- базовый AStarGrid2D для локального pathfinding.

После MVP:

- разные навигационные веса по биомам;
- реакция на свет;
- атака слабых построек;
- миграция.

## Сохранение мира

Сохранять не весь сгенерированный мир, а:

- seed;
- visited chunks;
- modified tiles;
- removed resource nodes;
- placed buildings;
- entity states для важных объектов;
- discovered POI.

Если генератор изменится, старые save могут ломаться. Поэтому после public build нужен migration strategy или фиксирование generator version.

## Генератор версии

Каждый мир хранит:

- `world_seed`;
- `generator_version`;
- `created_with_game_version`;
- `schema_version`.

При изменении генератора:

- старые миры могут использовать старый generator path;
- или мир мигрируется;
- или сейвы помечаются несовместимыми до early access.

## Читаемость top-down

Проблемы:

- деревья закрывают игрока;
- высокие объекты перекрывают здания;
- resource nodes похожи друг на друга;
- ночью игрок не видит threat source.

Решения:

- fade/highlight объектов над игроком;
- clear silhouettes;
- outline для interactable;
- light radius с мягкими границами;
- shadow не должна скрывать важные gameplay states.

