# Art and Audio

Status: `Draft`

## Art Direction

Top-down 2D with readable silhouettes, a warm base, and a dangerous outer world. The style can be stylized pixel art or hand-painted low-res, but systemic readability matters most.

## Visual Pillars

- The base looks handmade by the player.
- Machines have clear inputs, outputs, and state.
- Night visually changes the rules, but does not hide important information.
- Biomes differ not only by color, but also by object shapes.

## Camera

- Top-down or slight 3/4 top-down if it helps silhouettes.
- Camera follows the player smoothly.
- Zoom can be fixed for MVP.
- Do not make zoom too close: the player should see the base as a system.

## Scale

Create an art test early:

- character occupies one grid cell or slightly less;
- small machine is 1x1;
- furnace/generator is 2x2;
- storage is 1x1 or 2x1;
- trees/resource nodes should not fully hide the grid.

## Palette

Recommendation:

- starting zone: greens, soil, warm light;
- machines: metal, wood, amber indicators;
- night: cool shadows + warm light sources;
- danger: a contrasting accent, but not constant red noise.

Avoid one dominant hue across the whole game. Biomes should have different color temperatures.

## Animations

MVP animations:

- player idle/run;
- tool use;
- resource hit;
- item pickup;
- machine working loop;
- furnace fire;
- conveyor movement;
- enemy idle/move/attack;
- damage feedback.

Priority: state readability matters more than frame count.

## VFX

Needed:

- resource hit particles;
- construction dust;
- small glow for interactables;
- sparks/smoke for machines;
- warning pulse for threats;
- light radius at night.

VFX should support gameplay, not cover tiles.

## UI Art

- Item icons should differ by silhouette.
- Recipes should remain readable at small sizes.
- Machine status icons should be understandable after first exposure without text.
- Color coding is always backed by shape/icon.

## Sound

Audio pillars:

- manual gathering should feel good;
- the base should sound like a working system;
- night should change the atmosphere;
- threats should be heard before they attack.

## MVP SFX

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

## Music

MVP can start with ambience instead of full music:

- day ambience;
- night ambience;
- base hum;
- danger layer.

Later add adaptive music:

- exploration;
- base building;
- night pressure;
- event.

## Asset Pipeline

At the start:

- use placeholder art;
- set naming conventions immediately;
- do not mix final and prototype assets in the same folder.

Example:

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
