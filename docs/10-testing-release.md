# Тестирование и релиз

Статус: `Draft`

## Цель

Тестирование должно ловить поломки core loop: сбор, крафт, строительство, автоматизацию, сохранения, ночь/угрозы.

## Test pyramid для проекта

### Unit-like tests

Для чистой логики:

- inventory operations;
- item stack merge/split;
- recipe validation;
- craft cost checks;
- building placement rules;
- save migration;
- deterministic world generation.

### Scene tests

Для Godot-сцен:

- player movement scene loads;
- building ghost validates placement;
- machine accepts input and produces output;
- UI opens/closes without errors.

### Manual playtests

Для всего остального:

- первый день;
- первая ночь;
- первая автоматизация;
- save/load after building;
- death/respawn;
- performance with many machines.

## Smoke test checklist

Перед любым build:

- проект открывается в целевой версии Godot;
- main scene запускается без ошибок;
- можно начать новую игру;
- player двигается;
- можно собрать ресурс;
- inventory работает;
- можно построить объект;
- можно сохранить и загрузить;
- выход в меню не ломает состояние;
- нет красных ошибок в Godot Output при обычной игре 5 минут.

## Playtest checklist: первые 20 минут

Наблюдать:

- понял ли игрок первую цель без объяснения;
- нашел ли еду;
- построил ли campfire;
- понял ли ночь;
- понял ли крафт;
- где возникла первая фрустрация;
- какие элементы игрок не заметил.

Вопросы после:

- Что ты пытался сделать, но игра не позволила?
- Где было непонятно почему что-то не работает?
- Какую вещь хотелось автоматизировать первой?
- Было ли страшно/напряженно ночью?

## Performance targets

Для desktop MVP:

- 60 FPS на средней машине;
- 500 простых зданий без заметного падения;
- 1000 loose/conveyor items как stress target после optimization pass;
- save/load до 3 секунд для small world;
- отсутствие frame spikes при открытии inventory/build menu.

Числа будут уточняться после реального прототипа.

## Save/load тесты

Обязательные сценарии:

- save near base;
- save while machine working;
- save with blocked conveyor;
- save during night;
- save after player death;
- load old schema after migration;
- corrupted save handling.

## Регрессии Godot version upgrade

После обновления Godot:

- открыть проект и сохранить копию;
- запустить smoke test;
- проверить tilemap;
- проверить input;
- проверить shaders/materials, если есть;
- проверить exports;
- проверить save/load;
- записать результат в decisions log.

## Release checklist для demo

- version number выставлен;
- changelog написан;
- controls screen актуален;
- known issues список готов;
- debug shortcuts выключены или скрыты;
- crash/error logs доступны;
- save folder documented;
- build протестирован на чистой машине;
- archive naming единый.

## Bug report template

```md
## Summary

## Build version

## Steps to reproduce
1.
2.
3.

## Expected

## Actual

## Save/screenshots/logs

## Severity
Critical / High / Medium / Low
```

## Severity

- Critical: crash, save corruption, нельзя продолжить игру.
- High: ломает core loop или major system.
- Medium: заметная ошибка с workaround.
- Low: polish, visual, minor UX.

