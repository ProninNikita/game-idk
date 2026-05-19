# TODO

Working checklist for the first top-down survival automation prototype.

This file is the live task source. Keep UI and documentation text in English.

## Active Stability Pass

These tasks come from the architecture review and should be finished before adding more content-heavy systems.

### P0 - Runtime Correctness

- [x] Clear resource cell occupancy when harvested resource nodes deplete.
- [x] Drop completed prototype station craft outputs to the ground near the station instead of inserting them directly into the player inventory.
- [x] Add atomic inventory removal for prototype building costs and station recipe inputs.
- [x] Refund prototype building costs if placement fails after cost payment.
- [x] Block prototype gameplay actions while inventory or station UI is open.
- [x] Prevent HUD mouse clicks from leaking into mining or building placement.
- [x] Re-check station interaction range before starting recipes.
- [x] Auto-close station UI when the player moves out of interaction range.
- [x] Split HUD item summary and inventory capacity so one label does not overwrite the other.
- [x] Track placed building occupancy by building instance and release cells when a building leaves the tree.
- [ ] Add dynamic placement blockers so buildings cannot be placed on the player or future actors.
- [ ] Add all-or-nothing placement transactions that validate placement and cost through one authoritative path.
- [ ] Make UI blocking stop movement and automatic pickup while inventory or station UI is open.
- [ ] Prevent inventory and station windows from being open at the same time.
- [ ] Make building placement fail closed when a building definition has no explicit cost definition.
- [ ] Keep resource count and world debug metrics in sync when resources deplete or respawn.
- [ ] Ensure automated smoke tests do not leave generated files or dirty working tree state.

### P1 - Architecture Foundations

- [ ] Add `ItemDef`, `RecipeDef`, and `BuildingDef` data resources for ids, names, costs, recipes, footprints, stack sizes, icons, and save ids.
- [ ] Add a `DataRegistry` or equivalent loader so UI, building placement, crafting, and inventory read from the same definitions.
- [ ] Remove duplicated building costs and recipe text from `hud.gd`, `player_controller.gd`, `world.gd`, and `building_instance.gd`.
- [ ] Type core references directly where possible, especially `PlayerController.world` and `main.gd` scene references.
- [ ] Replace broad group/string contracts with small explicit contracts for buildable, harvestable, pickup, station, inventory, and saveable behavior.
- [ ] Create a single gameplay mode owner for normal play, inventory, station UI, build placement, pause, and main menu.
- [ ] Make building scenes self-describing through a definition id or definition resource.
- [ ] Add typed item stack and inventory slot models instead of anonymous slot dictionaries.
- [ ] Validate every runtime item id against the item registry before inventory, pickup, recipe, or save operations.
- [ ] Protect inventory resizing and save migrations from silently deleting items when slot counts shrink.
- [ ] Separate item, recipe, building, resource, and station id namespaces or use typed definition references.
- [ ] Move UI display text for costs, recipes, durations, and item names into shared definitions.
- [ ] Replace global group scans for resources, drops, and stations with spatial queries, local detection areas, or chunk registries before scaling item/building counts.

### P2 - Stations, Automation, and Simulation

- [ ] Add station input slots.
- [ ] Add station output slots.
- [ ] Make station recipes consume station inputs instead of directly consuming player inventory.
- [ ] Make station outputs stay in station output slots until collected or moved by automation.
- [ ] Drop station output overflow to the ground using the existing ground item pickup flow.
- [ ] Move station timers from per-node `_process` to a shared machine scheduler before scaling to many machines.
- [ ] Keep station timers independent from UI visibility.
- [ ] Move station crafting ownership out of `PlayerController` and into station/world simulation.
- [ ] Make station output spawning independent from player UI listeners.
- [ ] Preserve active craft recipe data or provide recipe migration rules so renamed recipes cannot consume inputs and produce nothing.
- [ ] Save and load active station jobs, remaining craft time, inputs, and outputs.
- [ ] Add blocked-output and missing-input station states.
- [ ] Stop rebuilding station recipe rows on every progress refresh; update existing row state instead.
- [ ] Display recipe duration from recipe data instead of hardcoded station UI text.

### P3 - Save, Load, and Tests

- [x] Add an automated pre-commit gameplay smoke test for the current prototype loop.
- [ ] Add save schema versioning.
- [ ] Add `to_save_data()` and `from_save_data()` for world state, player inventory, buildings, stations, ground items, and removed resources.
- [ ] Save generated-world diffs instead of serializing the whole generated map.
- [ ] Split destructive world generation from load/rebuild paths so saves are not overwritten by `_ready()`.
- [ ] Rebuild building occupancy from saved grid positions instead of persisting runtime instance ids.
- [ ] Add defensive load validation for missing definitions, bad ids, invalid positions, and corrupted inventory stacks.
- [ ] Add headless tests for resource occupancy cleanup.
- [ ] Add headless tests for building placement and payment rollback.
- [ ] Add headless tests for atomic inventory removal and locked slots.
- [ ] Add headless tests for station crafting, output drops, and future station slots.
- [ ] Add headless tests for save/load round trips.
- [ ] Add a timeout around the pre-commit smoke runner so commits cannot hang forever if Godot stalls.
- [ ] Add a smoke-test path that uses real viewport mouse/button events for UI click leak coverage.
- [ ] Add smoke-test coverage for failed building placement cost rollback.
- [ ] Add viewport-size smoke coverage for the inventory and station UI.

## Prototype Features

### Map and World

- [x] Create the starting 150x150 tile map.
- [x] Place basic resource zones: forest, stone clusters, ore veins, crop fields.
- [x] Add simple player navigation with map boundary limits.
- [x] Keep harvested resource cells buildable after depletion.
- [ ] Check tile and object readability in the Godot editor/runtime.
- [ ] Add biome regions and terrain rules.
- [ ] Add world chunking only when the current single-map approach becomes a bottleneck.

### Resources

- [x] Add resource nodes: trees, stone, ore, crops.
- [x] Configure durability and drop amounts for each resource type.
- [x] Make resource nodes breakable with the pickaxe.
- [x] Add placeholder feedback for hits, damage, and depletion.
- [x] Spawn ground item drops when destroyed resource nodes deplete.
- [ ] Add proper mining time and tool modifiers.
- [ ] Add resource respawn or regeneration rules.
- [ ] Make future resource respawn and chunk spawning check building occupancy before placing resources.
- [ ] Move resource definitions into data resources.

### Player and Tools

- [x] Implement basic player movement.
- [x] Add the pickaxe as the starting tool at the behavior level.
- [x] Configure the hit area and target check in front of the player.
- [x] Rotate or face the player toward the mouse cursor during aiming and harvesting.
- [ ] Restrict harvesting by tool type once swords and separate tools are added.
- [ ] Add tool durability or upgrade rules.
- [ ] Add equipment effects for armor and accessory slots.

### Inventory and Equipment

- [x] Add a simple inventory with item counts.
- [x] Automatically send picked-up resources to the inventory.
- [x] Show inventory status in the HUD.
- [x] Add proximity pickup for ground item drops.
- [x] Add inventory capacity, slot limits, and free-slot checks for pickup.
- [x] Build a dedicated inventory UI that shows slots, stack counts, and remaining capacity.
- [x] Add stack limits and overflow handling after the first smoke test.
- [x] Treat the top inventory row as the toolbelt/hotbar.
- [x] Lock the first hotbar slot as occupied by the starting pickaxe.
- [x] Provide 8 free hotbar slots after the starting pickaxe slot.
- [x] Make pickups fill hotbar slots before filling the separate inventory.
- [x] Add a separate inventory window toggled by the inventory key.
- [x] Add a visible toolbar UI for the hotbar slots.
- [x] Add right-side inventory window categories: Inventory, Building, Upgrades, Main Menu.
- [x] Add a left-side character equipment panel with Helmet, Armor, Gloves, Boots, Belt, and Amulet slots.
- [x] Keep the inventory key able to close the window after clicking category buttons.
- [x] Add atomic multi-item removal for prototype costs.
- [ ] Add item definitions with per-item stack sizes instead of a shared prototype stack size.
- [ ] Add actual equipping and stat effects for character equipment slots.
- [ ] Add drag/drop, split, merge, and quick-transfer inventory actions.
- [ ] Add stable slot save/load.

### Building

- [x] Add a working Building category in the inventory window.
- [x] Add a furnace building recipe costing 2 stone and 1 wood.
- [x] Add a forge building slot and recipe costing 4 stone and 2 ore.
- [x] Add a workbench building slot and recipe costing 2 wood and 1 stone.
- [x] Add building placement mode after pressing Create.
- [x] Add building placement mode for each Building category slot.
- [x] Restrict building placement to free grid cells near the player.
- [x] Add 2x2 furnace, forge, and workbench footprints.
- [x] Spend prototype building materials only through atomic removal.
- [x] Refund prototype building costs on failed placement.
- [x] Add a craftable 1x1 fence building.
- [x] Allow fence placement after crafting a fence item at the workbench.
- [ ] Add a dedicated building placement cursor and clearer blocked-cell feedback.
- [ ] Add building removal and refund rules.
- [ ] Add building health and destruction rules.
- [ ] Save and load placed buildings.
- [ ] Move building definitions and costs into data resources.

### Stations and Crafting

- [x] Define the first simple production chain: wood to coal, ore and coal to iron ingots, ingots to iron armor, wood to fence.
- [x] Add station interaction UI opened by pressing E while the cursor is over a nearby station.
- [x] Add 10-second craft timers for station recipes.
- [x] Add furnace recipes for coal and iron ingots.
- [x] Add a forge recipe for iron armor.
- [x] Add a workbench recipe for fences.
- [x] Drop completed craft outputs near the station for pickup.
- [x] Re-check station range before crafting.
- [x] Auto-close station UI when interaction becomes invalid.
- [ ] Add machine input and output slots instead of crafting directly from the player inventory.
- [ ] Add station recipe queues or explicit single-job rules.
- [ ] Add blocked-output behavior.
- [ ] Move recipes into data resources.

### Automation

- [ ] Add a basic placeable device for automated processing or gathering.
- [ ] Add a simple container/chest.
- [ ] Add conveyors or another first transport primitive.
- [ ] Verify that manual gathering and automation use the same item/resource data.
- [ ] Add machine diagnostics for missing input, blocked output, no fuel, and working state.

### UI and Controls

- [x] Add inventory toggle with Tab/I.
- [x] Keep gameplay actions blocked while inventory or station UI is open.
- [ ] Add one authoritative gameplay mode owner.
- [x] Split HUD item summary from capacity display.
- [ ] Stop rebuilding station recipe rows every progress update.
- [ ] Make inventory and station windows mutually exclusive.
- [ ] Block movement and automatic pickup while blocking gameplay input.
- [ ] Make the inventory window responsive below the default 1280px viewport width.
- [ ] Add focused keyboard/gamepad navigation later.
- [ ] Add pause/main menu behavior.

## Prototype Verification

- [x] Run an automated smoke test: start game, move, gather, place buildings, craft station outputs, and pick up output drops.
- [x] Verify that harvested resource cells can be built on.
- [x] Verify that UI clicks do not trigger mining or building placement.
- [ ] Verify that failed building placement does not consume materials.
- [x] Verify that station output stays on the ground until picked up.
- [ ] Define the minimum readiness criteria for the first playable build.
- [ ] Record found bugs and limitations in `CHANGELOG.md` or a separate task list.
- [x] Run the project in Godot 4.6.x stable after each architecture pass.
