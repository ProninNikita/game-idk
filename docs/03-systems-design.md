# Systems Design

Status: `Draft`

## Survival Systems

### Hunger

Purpose: make the player build food stability instead of exploring forever without preparation.

Prototype rules:

- hunger decreases constantly;
- physical work can increase hunger drain;
- raw food restores little and can carry risk;
- cooked food is more efficient;
- food automation should become the first major relief.

Balance goal: the player should not stare at the hunger bar constantly, but should plan food before expeditions.

### Temperature/Heat

For MVP, this can be simplified to night cold or seasonal cold:

- at night, without fire/clothing/shelter the character gets cold;
- cold increases hunger drain or reduces speed;
- heat sources have a radius.

Temperature should be spatial: the player understands where it is safe and where it is not.

### Light and Darkness

Light is not only visibility:

- it reduces night threat risk;
- it allows some buildings to work;
- it improves base readability;
- it can consume fuel/energy.

Current prototype time phases:

- Morning: 06:00-09:00.
- Day: 09:00-16:00.
- Evening: 16:00-22:00.
- Night: 22:00-06:00.

The current prototype uses a 12-minute full day by default and applies a smooth world tint as time advances. Threats, cold, light radius, and heat safety are still future systems.

### Health

Health is lost from:

- attacks;
- zero hunger;
- extreme temperature;
- poison/bad food;
- special events.

Regeneration:

- slow natural regen while fed;
- faster recovery through food/medicine;
- campfires or shelter can improve recovery.

## Player Tool

### Multitool Cutter

The current starting tool is the Multitool Cutter recovered from the escape capsule supplies. It should serve as the first shared verb for gathering, construction support, and emergency defense.

Prototype rules:

- holding the tool action activates the beam only while a nearby valid target is in the current aim direction;
- while active, the player can move and steer the beam with the mouse;
- the current target is outlined immediately when selected;
- the cutter keeps the current valid target while held, retargets only to valid targets inside laser range, and does not fire into empty ground;
- releasing the tool action immediately drops the lock and stops damage;
- the cutter deals gradual damage over time to the current target under the beam;
- depleted resources drop items on the ground through the existing pickup flow;
- future monsters should use the same lock-on damage path before specialized weapons are added.

## Automation

### Principle

Every automation should replace a repeated manual action:

- extract;
- transport;
- process;
- store;
- distribute;
- defend;
- support a resource like fuel or water.

### MVP Machines

- `Collector`: extracts a resource from a nearby tile or deposit.
- `Conveyor`: moves items in a direction.
- `Inserter/Arm`: transfers items between a machine and a container.
- `Furnace`: turns ore + fuel into ingots.
- `Forge`: crafts stronger metal tools and weapon parts.
- `Workbench/Assembler`: crafts a simple recipe.
- `Chest`: stores items.
- `Generator`: turns fuel into energy.

### Current Prototype Recipes

- Furnace: 2 wood -> 1 coal.
- Furnace: 1 ore + 1 coal -> 1 iron ingot.
- Forge: 10 iron ingots -> 1 iron armor.
- Workbench: 5 wood -> 1 fence.

All current station recipes take 10 seconds. The player loads required inputs into station input slots, starts the recipe from station storage, and collects completed outputs from station output slots. Output overflow drops onto the ground through the normal ground item pickup flow.

### Post-MVP Machines

- splitter;
- filter;
- pump;
- pipe;
- farm plot;
- sprinkler;
- freezer/dryer;
- repair station;
- research station.

### Logistics

Starting decision: grid-based conveyor network.

Rules:

- an item occupies a slot on a conveyor;
- each conveyor has a direction;
- turns are either tile state or automatic connection;
- splitter/filter arrive after the basic prototype;
- if output is full, items stop and the machine blocks.

Important goal: the player should see why a chain stopped without debug UI.

## Crafting and Recipes

### Recipe

A recipe should have:

- id;
- display name;
- inputs;
- outputs;
- craft time;
- station type;
- required tech;
- tags.

### Manual Crafting

Manual crafting:

- fast for basic items;
- slow or impossible for machine parts;
- should not compete with automation in mid-game.

### Station Crafting

Stations:

- limit available recipes;
- have queues;
- can consume energy/fuel;
- can be automated through input/output.

## Energy

For MVP, energy can be simple:

- a generator has an internal fuel slot;
- machines have `energy_per_second`;
- the energy network works through radius or grid connection.

Options:

- Radius: simpler, less logistics.
- Wires/poles: more interesting, but needs UI and pathing.

MVP recommendation: start with generator radius, then move to poles if it creates meaningful decisions.

## Threats

Threats should attack weak points in the system:

- darkness;
- machine noise;
- food smell;
- open storage;
- distant expeditions;
- pollution or overheating, if added later.

MVP threat:

- a simple creature/shadow appears at night;
- avoids light;
- attacks the player or unprotected buildings;
- has a clear warning.

## Ecology

Ecology keeps the world from being an infinite warehouse:

- plants can regrow;
- deposits deplete;
- animals/creatures migrate;
- excessive extraction can change local conditions;
- farms require water/light/temperature.

For MVP:

- trees/bushes respawn or can be planted;
- ore is finite near the base;
- food regrows slowly;
- farms solve long-term food.

## Events

Events create rhythm:

- cold night;
- raid;
- storm;
- harvest day;
- power outage/overload;
- rare resource appearance.

MVP: one event after several days, clearly telegraphed.

## Exploration

Exploration should move the player beyond the base:

- new biomes provide unique resources;
- danger increases with distance;
- temporary outposts help logistics;
- the map should preserve discovered points of interest.
