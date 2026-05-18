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
- `Workbench/Assembler`: crafts a simple recipe.
- `Chest`: stores items.
- `Generator`: turns fuel into energy.

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
