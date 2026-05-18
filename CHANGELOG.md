# Changelog

Файл для истории версий, новых фич, изменений баланса, исправлений и технических решений, которые важны для игроков или разработки.

Формат основан на Keep a Changelog: https://keepachangelog.com/

## Как вести

- Все новые фичи сначала добавлять в `Unreleased`.
- При выпуске версии переносить записи из `Unreleased` в новый блок версии.
- Версии вести в формате `MAJOR.MINOR.PATCH`.
- Для прототипов можно использовать `0.x.y`.

## Типы изменений

- `Added` - новые фичи, документы, контент, системы.
- `Changed` - изменения существующего поведения, баланса или структуры.
- `Fixed` - исправления ошибок.
- `Removed` - удаленные фичи, данные или документы.
- `Technical` - внутренние изменения архитектуры, инструментов, пайплайна.
- `Known Issues` - известные проблемы версии.

## [Unreleased]

### Added

- Документ истории версий и изменений.
- Git-ready структура для старта проекта.

### Changed

- README и индекс документации обновлены ссылкой на changelog.

### Fixed

- Пока нет.

### Technical

- Подготовлен `.gitignore` для Godot-проекта.

### Known Issues

- Локально установлен Godot 4.3, а рекомендованная версия проекта - Godot 4.6.x stable.

## [0.1.0] - 2026-05-18

### Added

- Стартовая документация проекта:
  - vision;
  - Game Design Document;
  - systems design;
  - Godot technical design;
  - data and balance;
  - world generation;
  - UI/UX;
  - art and audio;
  - production roadmap;
  - testing and release;
  - backlog;
  - decisions and risks;
  - coding standards;
  - content pipeline.
- Зафиксирована рекомендация по движку: Godot 4.6.x stable.
- Зафиксирована текущая проверенная стабильная версия Godot на 18 мая 2026: Godot 4.6.2-stable.
- Зафиксирована локальная версия Godot: 4.3.stable.official.

### Technical

- Создана базовая файловая структура документации.

