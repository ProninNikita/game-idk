# Производственный план

Статус: `Draft`

## Принцип

Сначала playable prototype, потом vertical slice, потом расширение. Не строить десятки систем до проверки core loop.

## Phase 0: Подготовка проекта

Цель: рабочая Godot-среда и документационный baseline.

Done:

- выбран target Godot;
- создана документация;
- определен MVP scope.

Следующее:

- обновить локальный Godot до 4.6.x stable;
- создать Godot project;
- настроить Git;
- создать базовую структуру папок;
- добавить placeholder assets.

## Phase 1: Movement and Interaction Prototype

Цель: игрок приятно двигается и взаимодействует с миром.

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

- можно собрать wood/stone/food;
- предметы попадают в inventory;
- игрок понимает selected tool/action;
- управление ощущается нормально.

## Phase 2: Survival Prototype

Цель: мир начинает давить на игрока.

Scope:

- hunger;
- health;
- day/night cycle;
- campfire;
- simple food/cooking;
- first night threat;
- death/respawn loop.

Exit criteria:

- первая ночь создает напряжение;
- игрок понимает, как подготовиться;
- голод заставляет заботиться о еде, но не раздражает каждую минуту.

## Phase 3: Building and Crafting Prototype

Цель: игрок строит базу.

Scope:

- build mode;
- ghost placement;
- workbench;
- furnace;
- chest;
- recipes;
- simple building save state.

Exit criteria:

- можно построить маленький лагерь;
- крафт и строительство используют одни item definitions;
- здания сохраняются/загружаются.

## Phase 4: Automation Prototype

Цель: первая производственная цепочка работает без участия игрока.

Scope:

- collector;
- conveyor;
- inserter/arm;
- furnace automation;
- machine states;
- blocked output handling;
- visible status icons.

Exit criteria:

- можно автоматизировать хотя бы одну цепочку;
- остановки машин понятны визуально;
- симуляция не завязана на хаотичный per-node logic.

## Phase 5: Vertical Slice

Цель: 30-60 минут цельного gameplay.

Scope:

- small generated/handcrafted world;
- 3-4 biomes/zones;
- tech progression до Tier 2;
- first event;
- base defense;
- save/load;
- audio/VFX pass;
- UI polish pass.

Exit criteria:

- новый игрок понимает первые цели;
- есть 3-5 значимых решений;
- можно проиграть из-за плохой подготовки;
- можно восстановиться после ошибки;
- есть причина расширять базу.

## Phase 6: Alpha

Цель: все главные системы есть, контент еще может быть грубым.

Scope:

- chunk generation;
- multiple biomes;
- broader tech tree;
- advanced logistics;
- more threats/events;
- balance pass;
- performance pass.

Exit criteria:

- игра держит несколько часов прогрессии;
- save format стабилен;
- major systems не переписываются каждую неделю.

## Phase 7: Beta

Цель: стабилизация и контент.

Scope:

- bug fixing;
- UX polish;
- tutorial/onboarding;
- final art/audio pass;
- localization prep;
- Steam page assets if needed;
- demo build.

Exit criteria:

- known critical bugs закрыты;
- performance targets достигнуты;
- tutorial не ломается;
- game loop понятен playtesters.

## Milestone naming

- M0 Docs and setup.
- M1 Hands in the dirt.
- M2 First night.
- M3 First base.
- M4 First machine.
- M5 Vertical slice.

## Weekly rhythm

- Понедельник: выбрать 3-5 задач недели.
- Середина недели: короткий playable check.
- Конец недели: build + notes + backlog cleanup.

Даже solo-проекту полезен build в конце недели. Он показывает реальное состояние, а не настроение.

