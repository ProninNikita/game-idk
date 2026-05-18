# Пайплайн контента

Статус: `Draft`

## Цель

Добавление нового контента должно быть повторяемым: предметы, рецепты, здания, машины и биомы проходят один и тот же путь от идеи до playable проверки.

## Общий процесс

1. Описать роль контента в дизайне.
2. Добавить data definition.
3. Добавить placeholder visual/audio, если нужно.
4. Подключить к registry.
5. Добавить рецепт или unlock condition.
6. Проверить в test map.
7. Записать баланс-заметки.

Если контент не меняет решение игрока, он не приоритетен для MVP.

## Добавление предмета

Checklist:

- [ ] Есть `id`.
- [ ] Есть display name.
- [ ] Есть category/tags.
- [ ] Есть stack size.
- [ ] Есть icon.
- [ ] Есть source: где предмет появляется.
- [ ] Есть sink: куда предмет тратится.
- [ ] Предмет проверен в inventory.

Пример:

```text
id: iron_ore
category: raw
tags: ore, smeltable
stack_size: 50
source: rocky_field nodes, collector
sink: furnace -> iron_ingot
```

## Добавление рецепта

Checklist:

- [ ] Все input items существуют.
- [ ] Все output items существуют.
- [ ] Время крафта задано.
- [ ] Station type задан.
- [ ] Unlock condition задан или явно `none`.
- [ ] Рецепт не ломает progression gate.
- [ ] Рецепт проверен вручную и на станции.

Баланс-вопросы:

- Что игрок делал до этого рецепта?
- Что рецепт теперь облегчает?
- Какая новая проблема появляется после открытия?

## Добавление здания

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

Для машин дополнительно:

- [ ] Input slots.
- [ ] Output slots.
- [ ] Processing state.
- [ ] Blocked state.
- [ ] Fuel/energy need, если есть.
- [ ] Tick behavior.

## Добавление биома

Checklist:

- [ ] Gameplay role.
- [ ] Terrain tiles.
- [ ] Resource distribution.
- [ ] Threat profile.
- [ ] Unique reward.
- [ ] Traversal rule, если есть.
- [ ] Audio/ambience.
- [ ] Map color/marker.

Биом должен отвечать минимум на один вопрос:

- Зачем игрок сюда идет?
- Почему здесь опасно или неудобно?
- Что здесь можно сделать, чего нельзя в стартовой зоне?

## Добавление угрозы

Checklist:

- [ ] Purpose.
- [ ] Spawn rule.
- [ ] Telegraph.
- [ ] Attack/pressure.
- [ ] Counterplay.
- [ ] Reward or relief after dealing with it.
- [ ] Save/load relevance.

Угроза без counterplay раздражает. Угроза без telegraph кажется нечестной.

## Placeholder policy

Placeholder допустим, если:

- он явно лежит в `prototype`;
- его легко заменить;
- он не маскирует gameplay readability проблемы.

Placeholder опасен, если:

- все предметы выглядят одинаково;
- машина не показывает направление;
- threat не читается;
- UI строится вокруг временной картинки.

## Контентные таблицы

На старте можно держать данные в Godot Resources. Если баланс часто меняется, добавить экспорт/импорт CSV.

Возможные таблицы:

- items;
- recipes;
- buildings;
- machines;
- biomes;
- threats;
- tech unlocks.

## Definition of done для нового контента

Контент считается добавленным, если:

- его можно получить в игре;
- его можно использовать в игре;
- он сохраняется/загружается, если остается в мире;
- он имеет readable placeholder/final visual;
- он упомянут в нужном design или balance документе;
- он не создает красных ошибок в Output.

