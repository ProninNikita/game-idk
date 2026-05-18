# TODO

A short checklist for the first top-down survival automation prototype.

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
- [ ] Add item definitions with per-item stack sizes instead of a shared prototype stack size.

## Automation

- [ ] Define the first simple production chain.
- [ ] Add a basic placeable device for processing or gathering.
- [ ] Configure input and output slots for the device.
- [ ] Verify that manual gathering and automation use the same resource data.

## Prototype Verification

- [ ] Run a manual smoke test: start game, move, gather wood/stone/ore/crops, verify inventory pickup.
- [ ] Define the minimum readiness criteria for the first playable build.
- [ ] Record found bugs and limitations in `CHANGELOG.md` or a separate task list.
- [ ] Run the project in Godot 4.6.x stable after installing/updating the editor.
