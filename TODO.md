# TODO

A short checklist for the first top-down survival automation prototype.

## Architecture and Code Review Priorities

### P0 - Correctness Boundaries

- [ ] Clean up occupancy ownership: centralize placed-object cell reservation and release, make footprint queries authoritative, and clear cells when buildings are removed, replaced, or fail to load.
- [x] Clear resource cell occupancy when harvested resource nodes deplete.
- [ ] Define the building lifecycle: preview, paid, placed, active, and removed states should unregister occupancy, station references, UI focus, and save data at the correct time.
- [ ] Make building payments transactional: validate placement and costs together, spend ingredients only after placement commits, and roll back partial changes on failure.
- [x] Refund prototype building costs if placement fails after cost payment.
- [x] Add atomic inventory removal for prototype building costs and station recipe inputs.
- [ ] Separate UI/gameplay modal state: route inventory, building, station, and main menu modes through one modal owner so input, placement, movement, and cursor targeting cannot conflict.
- [x] Block prototype gameplay actions while inventory or station UI is open, and prevent HUD mouse clicks from leaking into mining or placement.
- [ ] Add save/load boundaries for buildings, stations, inventories, ground drops, and production timers; load invalid data defensively without corrupting occupancy or inventory.

### P1 - Data and Systems Contracts

- [ ] Add a data registry for items, recipes, buildings, stations, footprints, stack sizes, icons, and save ids; remove duplicated literals from UI and gameplay scripts.
- [ ] Introduce typed world/contracts for buildable, interactable, inventory, station, and saveable behavior so systems do not depend on scene or node-name assumptions.
- [ ] Split station input and output inventories from the player inventory; recipes should consume only station inputs and place results into station outputs.
- [x] Drop completed prototype station craft outputs to the ground near the station instead of inserting them directly into the player inventory.
- [ ] Drop station overflow output to the ground when output inventory is full, using existing ground-drop pickup rules and clear ownership/positioning.
- [ ] Add a machine scheduler that processes station jobs and timers independently from UI visibility and survives pause, save, and load transitions.
- [ ] Make UI row updates data-driven so inventory, building, upgrades, and station rows refresh from registry/state changes instead of manual per-row wiring.

### P2 - Validation and Project Hygiene

- [ ] Add tests for placement occupancy, payment rollback, inventory atomic removal, station input/output flow, overflow ground drops, scheduler ticks, and save/load reconstruction.
- [ ] Sync docs after architecture changes: update `README.md`, `CHANGELOG.md`, and gameplay notes once implementation lands.

## Map and World

- [x] Create the starting 150x150 tile map.
- [x] Place basic resource zones: forest, stone clusters, ore veins, crop fields.
- [x] Add simple player navigation with map boundary limits.
- [ ] Check tile and object readability in the Godot editor/runtime.

## Resources

- [x] Add resource nodes: trees, stone, ore, crops.
- [x] Configure durability and drop amounts for each resource type.
- [x] Make resource nodes breakable with the pickaxe.
- [x] Add placeholder feedback for hits, damage, and depletion.
- [x] Spawn ground item drops when destroyed resource nodes deplete.
- [ ] Add proper mining time and tool modifiers.

## Player and Tools

- [x] Implement basic player movement.
- [x] Add the pickaxe as the starting tool at the behavior level.
- [x] Configure the hit area and target check in front of the player.
- [x] Rotate or face the player toward the mouse cursor during aiming and harvesting.
- [ ] Restrict harvesting by tool type once swords and separate tools are added.

## Inventory

- [x] Add a simple inventory with item counts.
- [x] Automatically send picked-up resources to the inventory.
- [x] Show the inventory in a minimal UI.
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
- [ ] Add item definitions with per-item stack sizes instead of a shared prototype stack size.
- [ ] Add actual equipping and stat effects for the character equipment slots.

## Building

- [x] Add a working Building category in the inventory window.
- [x] Add a furnace building recipe costing 2 stone and 1 wood.
- [x] Add a forge building slot and recipe costing 4 stone and 2 ore.
- [x] Add a workbench building slot and recipe costing 2 wood and 1 stone.
- [x] Add building placement mode after pressing Create Furnace.
- [x] Add building placement mode for each Building category slot.
- [x] Restrict furnace placement to free grid cells near the player.
- [x] Add a 2x2 furnace footprint.
- [x] Add 2x2 forge and workbench footprints.
- [x] Spend furnace materials only after successful placement.
- [x] Spend forge and workbench materials only after successful placement.
- [x] Add a craftable 1x1 fence building.
- [x] Allow fence placement after crafting a fence item at the workbench.
- [ ] Add a dedicated building placement cursor and clearer blocked-cell feedback.
- [ ] Add building removal and refund rules.
- [ ] Save and load placed buildings.

## Automation

- [x] Define the first simple production chain: wood to coal, ore and coal to iron ingots, ingots to iron armor, wood to fence.
- [x] Add station interaction UI opened by pressing E while the cursor is over a nearby station.
- [x] Add 10-second craft timers for station recipes.
- [x] Add furnace recipes for coal and iron ingots.
- [x] Add a forge recipe for iron armor.
- [x] Add a workbench recipe for fences.
- [ ] Add machine input and output slots instead of crafting directly from the player inventory.
- [ ] Add a basic placeable device for automated processing or gathering.
- [ ] Verify that manual gathering and automation use the same resource data.

## Prototype Verification

- [ ] Run a manual smoke test: start game, move, gather wood/stone/ore/crops, verify inventory pickup.
- [ ] Define the minimum readiness criteria for the first playable build.
- [ ] Record found bugs and limitations in `CHANGELOG.md` or a separate task list.
- [ ] Run the project in Godot 4.6.x stable after installing/updating the editor.
