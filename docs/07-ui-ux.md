# UI/UX и управление

Статус: `Draft`

## UX-цель

Игрок должен понимать, что происходит с персонажем, базой и производством, не утопая в окнах. UI должен помогать строить и диагностировать системы.

## Управление PC

| Действие | Клавиатура/мышь |
| --- | --- |
| Движение | WASD |
| Interact / use tool | ЛКМ или E |
| Alternate action | ПКМ |
| Inventory | Tab или I |
| Crafting/build menu | B |
| Rotate building | R |
| Quick slots | 1-9 |
| Map | M |
| Pause | Esc |

Финальные бинды зафиксировать после прототипа.

## Gamepad позже

Gamepad не MVP, но архитектурно стоит не мешать:

- все действия через InputMap;
- UI поддерживает focus navigation;
- building placement может использовать right stick/cursor mode.

## HUD

HUD MVP:

- health;
- hunger;
- temperature/heat warning, если включено;
- day/night clock;
- quickbar;
- selected item/tool;
- короткие status icons;
- contextual prompt.

HUD не должен закрывать центр экрана и grid под ногами игрока.

## Инвентарь

Принципы:

- grid inventory;
- stack splitting;
- quick transfer;
- sort;
- filter позже;
- item tooltip с назначением и рецептами позже.

MVP:

- открыть/закрыть;
- drag/drop;
- transfer to chest;
- quickbar assignment.

## Крафт UI

Должен показывать:

- доступные рецепты;
- недостающие ресурсы;
- время крафта;
- где крафтится;
- что откроется после постройки станции.

Не делать огромный tech tree в MVP. Достаточно списка рецептов по категориям.

## Строительство UI

Обязательные состояния:

- ghost preview;
- valid placement;
- invalid placement с причиной;
- rotation;
- cost display;
- footprint;
- input/output direction для машин.

Причины invalid placement:

- нет ресурсов;
- занято;
- непроходимо;
- wrong terrain;
- outside build range;
- missing foundation, если появится.

## Диагностика машин

Каждая машина должна визуально показывать:

- работает;
- нет входного ресурса;
- output blocked;
- нет топлива;
- нет энергии;
- повреждена;
- выключена.

Лучше использовать маленькие icons/status lights, а не длинный текст над каждой машиной.

## Карта

MVP:

- fog of war/discovered areas;
- player marker;
- base marker;
- POI markers after discovery.

Позже:

- custom pins;
- resource overlay;
- danger overlay;
- logistics overlay.

## Оверлеи

Полезные режимы:

- build grid;
- energy radius/network;
- heat radius;
- light radius;
- logistics flow;
- danger/noise.

Не включать все сразу в MVP. Первый обязательный overlay - build grid + placement validity.

## Обратная связь

Нужны:

- звук подбора;
- hit spark/impact;
- small item pop;
- machine start/stop;
- warning pulse при голоде/ночной угрозе;
- screen edge hint для угрозы вне экрана, если честно работает.

## Accessibility

Сразу закладывать:

- remappable controls;
- readable font sizes;
- color + icon, не только цвет;
- adjustable screenshake;
- separate volumes: master/music/sfx/ambience;
- pause в single-player.

## UX-проверки

На каждом playtest:

- игрок понял, что делать в первые 60 секунд?
- игрок понял, почему машина остановилась?
- игрок понял, почему нельзя поставить здание?
- игрок смог найти нужный рецепт?
- игрок видит угрозу до получения урона?

