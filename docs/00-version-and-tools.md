# Версии и инструменты

Статус: `Draft`

## Проверка Godot на 18 мая 2026

По официальному архиву Godot:

- последняя стабильная версия: **Godot 4.6.2-stable**, опубликована 1 апреля 2026;
- свежая RC-версия: **Godot 4.6.3-rc2**, опубликована 16 мая 2026;
- свежая beta-ветка: **Godot 4.7-beta2**, опубликована 11 мая 2026.

Решение для проекта: **начинать на Godot 4.6.2-stable** или на последнем стабильном патче ветки `4.6.x`, когда `4.6.3` станет stable. Beta/RC не использовать как основную версию проекта, пока нет конкретной фичи, ради которой нужен риск.

Источники:

- https://godotengine.org/download/archive/
- https://docs.godotengine.org/en/stable/about/release_policy.html

## Локальная среда

Проверка локального приложения:

```text
/Applications/Godot.app/Contents/MacOS/Godot --version
4.3.stable.official.77dcf97d8
```

Повторная проверка во время создания первого Godot-скелета показала, что приложение по этому пути больше не найдено. Перед runtime smoke test нужно установить или переустановить Godot 4.6.x stable.

Рекомендация: перед созданием проекта обновить локальный Godot до **4.6.2-stable** или свежей стабильной версии `4.6.x`.

## Базовый стек

- Engine: Godot 4.6.x stable.
- Language: GDScript для первого прототипа.
- Rendering: 2D, top-down, orthographic-style camera through `Camera2D`.
- Physics: встроенная 2D physics Godot, без внешнего движка.
- Data format: `.tres`/`.res` для ресурсов Godot, JSON/CSV только для внешних таблиц баланса при необходимости.
- Save format: versioned JSON или binary Resource save; выбирать после первого прототипа сохранений.
- Version control: Git.

## Почему GDScript сначала

GDScript быстрее для итераций в Godot, хорошо интегрируется с editor tooling и достаточно удобен для систем уровня MVP. C# можно рассмотреть позже, если появятся тяжелые симуляции, editor tooling на C# или потребность в строгой типизации на большом объеме кода.

## Правила обновления Godot

Обновляться можно:

- перед началом milestone;
- после создания backup/commit;
- после чтения release notes;
- если версия является stable;
- если проект проходит smoke-тест после открытия в новой версии.

Не обновляться:

- в середине стабилизации билда;
- перед playtest без времени на регрессию;
- на beta/RC без отдельной экспериментальной ветки проекта.

## Минимальные инструменты разработки

- Godot 4.6.x stable.
- Git.
- Редактор кода: Godot script editor, VS Code или Cursor.
- Таблицы баланса: LibreOffice, Google Sheets или CSV в репозитории.
- Диаграммы: Mermaid в Markdown или Excalidraw.
- Трекер задач: Markdown-бэклог на старте, потом можно перейти в GitHub Issues/Linear.

## Project Settings, которые стоит зафиксировать в начале

- Window stretch mode: `canvas_items`.
- Window stretch aspect: `expand`.
- Physics ticks per second: начать с дефолта, менять только после профилирования.
- Input map: фиксировать имена действий сразу, не привязывать механику к конкретным клавишам.
- Rendering: держать 2D pipeline простым до появления реальной потребности в custom shaders.

## Целевые платформы

Старт:

- Windows desktop.
- macOS desktop.
- Linux desktop.

Позже:

- Steam Deck, если управление и UI хорошо работают с gamepad.

Не планировать на старте:

- mobile;
- web export;
- console ports.
