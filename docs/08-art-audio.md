# Арт и аудио

Статус: `Draft`

## Арт-направление

Top-down 2D с читаемыми силуэтами, теплой базой и опасным внешним миром. Стиль может быть stylized pixel art или hand-painted low-res, но главное - системная читаемость.

## Визуальные pillars

- База выглядит сделанной руками игрока.
- Машины имеют понятные входы, выходы и состояние.
- Ночь визуально меняет правила, но не скрывает важную информацию.
- Биомы отличаются не только цветом, но и формой объектов.

## Камера

- Top-down или slight 3/4 top-down, если это помогает силуэтам.
- Камера следует за игроком плавно.
- Zoom может быть фиксированным на MVP.
- Не делать слишком близкий zoom: игрок должен видеть базу как систему.

## Масштаб

Нужно быстро сделать art test:

- персонаж занимает 1 grid cell или чуть меньше;
- маленькая машина 1x1;
- furnace/generator 2x2;
- storage 1x1 или 2x1;
- tree/resource nodes не должны закрывать grid полностью.

## Палитра

Рекомендация:

- стартовая зона: зелень, земля, теплый свет;
- машины: металл, дерево, янтарные индикаторы;
- ночь: холодные тени + теплые источники света;
- опасность: контрастный акцент, но не постоянный красный шум.

Избегать одного доминирующего оттенка на всю игру. Биомы должны иметь разные цветовые температуры.

## Анимации

MVP-анимации:

- idle/run игрока;
- use tool;
- hit resource;
- item pickup;
- machine working loop;
- furnace fire;
- conveyor movement;
- enemy idle/move/attack;
- damage feedback.

Приоритет: читаемость состояния важнее количества кадров.

## VFX

Нужны:

- resource hit particles;
- dust при строительстве;
- small glow для interactable;
- sparks/smoke для машин;
- warning pulse для угроз;
- light radius ночью.

VFX должны помогать gameplay, а не закрывать тайлы.

## UI art

- Иконки предметов должны различаться по силуэту.
- Рецепт должен читаться при маленьком размере.
- Status icons для машин должны быть понятны без текста после первого знакомства.
- Цветовая кодировка всегда дублируется формой/иконкой.

## Звук

Аудио pillars:

- ручной сбор должен быть приятным;
- база должна звучать как работающая система;
- ночь должна менять атмосферу;
- угрозы должны быть слышны до атаки.

## SFX MVP

- footsteps by terrain;
- tool swing;
- resource hit;
- resource break;
- pickup;
- inventory move;
- craft complete;
- building place/remove;
- machine start/loop/stop;
- fire loop;
- night warning;
- enemy approach/attack/damage;
- player damage/death.

## Музыка

MVP можно начать с ambience вместо полноценной музыки:

- day ambience;
- night ambience;
- base hum;
- danger layer.

Позже добавить adaptive music:

- exploration;
- base building;
- night pressure;
- event.

## Asset pipeline

На старте:

- использовать placeholder art;
- naming convention сразу;
- не смешивать final и prototype ассеты в одной папке.

Пример:

```text
art/
  sprites/
    prototype/
    player/
    resources/
    buildings/
    machines/
    ui/
```

## Naming

- `spr_player_run_01.png`
- `spr_machine_furnace_idle.png`
- `spr_machine_furnace_work.png`
- `sfx_pickup_wood_01.wav`
- `amb_night_forest_loop.ogg`

