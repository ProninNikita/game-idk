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
- [ ] Add proper mining time and tool modifiers.

## Player and Tools

- [x] Implement basic player movement.
- [x] Add the pickaxe as the starting tool at the behavior level.
- [x] Configure the hit area and target check in front of the player.
- [ ] Restrict harvesting by tool type once swords and separate tools are added.

## Inventory

- [x] Add a simple inventory with item counts.
- [x] Automatically send gathered resources to the inventory.
- [x] Show the inventory in a minimal UI.
- [x] Temporarily define the prototype inventory as unlimited.
- [ ] Add stack limits and overflow handling after the first smoke test.

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
