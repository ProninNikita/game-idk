# UI/UX and Controls

Status: `Draft`

## UX Goal

The player should understand what is happening with the character, base, and production without drowning in windows. UI should help build and diagnose systems.

## PC Controls

| Action | Keyboard/Mouse |
| --- | --- |
| Movement | WASD |
| Interact / use tool | Left Mouse Button or E |
| Alternate action | Right Mouse Button |
| Inventory | Tab or I |
| Crafting/build menu | B |
| Rotate building | R |
| Quick slots | 1-9 |
| Map | M |
| Pause | Esc |

Final bindings should be locked after the prototype.

## Gamepad Later

Gamepad is not MVP, but the architecture should not block it:

- all actions go through InputMap;
- UI supports focus navigation;
- building placement can use right stick/cursor mode.

## HUD

MVP HUD:

- health;
- hunger;
- temperature/heat warning, if enabled;
- day/night clock;
- quickbar;
- selected item/tool;
- short status icons;
- contextual prompt.

HUD should not cover the center of the screen or the grid under the player.

## Inventory

Principles:

- grid inventory;
- stack splitting;
- quick transfer;
- sorting;
- filters later;
- item tooltip with purpose and recipes later.

MVP:

- open/close;
- close reliably with Tab or I even after category buttons receive focus;
- right-side categories for Inventory, Building, Upgrades, and Main Menu;
- left-side character equipment slots for Helmet, Armor, Gloves, Boots, Belt, and Amulet;
- drag/drop;
- transfer to chest;
- quickbar assignment.

## Crafting UI

Should show:

- available recipes;
- missing resources;
- craft time;
- station requirement;
- what a new station unlocks.

Do not build a huge tech tree in MVP. A categorized recipe list is enough.

Current prototype station UI:

- opens when the cursor is over a nearby Furnace, Forge, or Workbench and the player presses E;
- shows recipe inputs, output, and 10-second craft time;
- disables recipe buttons while a station is crafting or when the player lacks ingredients;
- closes with the Close button or Esc.

## Building UI

Required states:

- building slots for available stations;
- ghost preview;
- valid placement;
- invalid placement with reason;
- rotation;
- cost display;
- footprint;
- input/output direction for machines.

Invalid placement reasons:

- not enough resources;
- occupied;
- blocked terrain;
- wrong terrain;
- outside build range;
- missing foundation, if added.

## Machine Diagnostics

Every machine should visually show:

- working;
- missing input resource;
- output blocked;
- no fuel;
- no energy;
- damaged;
- turned off.

Use small icons/status lights rather than long text above every machine.

## Map

MVP:

- fog of war/discovered areas;
- player marker;
- base marker;
- POI markers after discovery.

Later:

- custom pins;
- resource overlay;
- danger overlay;
- logistics overlay.

## Overlays

Useful modes:

- build grid;
- energy radius/network;
- heat radius;
- light radius;
- logistics flow;
- danger/noise.

Do not add everything at once in MVP. The first required overlay is build grid + placement validity.

## Feedback

Needed:

- pickup sound;
- hit spark/impact;
- small item pop;
- machine start/stop;
- warning pulse for hunger/night danger;
- screen-edge hint for offscreen threats, if implemented honestly.

## Accessibility

Plan from the start:

- remappable controls;
- readable font sizes;
- color + icon, not color alone;
- adjustable screenshake;
- separate volumes: master/music/sfx/ambience;
- pause in single-player.

## UX Checks

At each playtest:

- did the player understand what to do in the first 60 seconds?
- did the player understand why a machine stopped?
- did the player understand why a building could not be placed?
- could the player find the needed recipe?
- does the player see a threat before taking damage?
