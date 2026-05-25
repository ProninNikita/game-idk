extends SceneTree

const MAIN_SCENE_PATH: String = "res://scenes/main/main.tscn"
const BUILDING_NAMES: Dictionary = {
	&"furnace": "Furnace",
	&"forge": "Forge",
	&"workbench": "Workbench",
	&"fence": "Fence",
}

class FailedPlacementWorld:
	extends Node

	var backing_world: HearthlineWorld = null


	func _init(new_backing_world: HearthlineWorld) -> void:
		backing_world = new_backing_world


	func get_building_definition(building_id: StringName) -> Dictionary:
		return backing_world.get_building_definition(building_id)


	func get_tile_size() -> int:
		return backing_world.get_tile_size()


	func world_to_grid(world_position: Vector2) -> Vector2i:
		return backing_world.world_to_grid(world_position)


	func grid_to_world_center(grid_position: Vector2i, footprint: Vector2i = Vector2i.ONE) -> Vector2:
		return backing_world.grid_to_world_center(grid_position, footprint)


	func can_place_building(building_id: StringName, grid_position: Vector2i) -> bool:
		return backing_world.can_place_building(building_id, grid_position)


	func place_building(_building_id: StringName, _grid_position: Vector2i) -> bool:
		return false


	func spawn_ground_item(item_id: StringName, amount: int, spawn_position: Vector2, source_color: Color = Color(0.92, 0.78, 0.28)) -> Node:
		return backing_world.spawn_ground_item(item_id, amount, spawn_position, source_color)

var _main: Node = null
var _world: HearthlineWorld = null
var _player: PlayerController = null
var _hud: HearthlineHUD = null
var _failures: Array[String] = []
var _pressed_buttons: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("[smoke] Starting pre-commit gameplay smoke test")
	await _load_main_scene()
	await _verify_startup_state()
	await _verify_time_of_day_cycle()
	await _verify_movement_and_mouse_facing()
	await _verify_inventory_window_buttons()
	await _verify_harvest_drop_pickup()
	await _verify_building_buttons_and_placement()
	await _verify_station_buttons_crafting_and_pickup()
	await _verify_station_auto_close()
	await _verify_building_occupancy_release()
	_finish()


func _load_main_scene() -> void:
	var packed: PackedScene = load(MAIN_SCENE_PATH) as PackedScene
	_expect(packed != null, "Main scene can be loaded")
	if packed == null:
		return

	_main = packed.instantiate()
	root.add_child(_main)
	await process_frame
	await physics_frame

	_world = _main.get_node_or_null("World") as HearthlineWorld
	_player = _main.get_node_or_null("Player") as PlayerController
	_hud = _main.get_node_or_null("HUD") as HearthlineHUD
	_expect(_world != null, "World node exists")
	_expect(_player != null, "Player node exists")
	_expect(_hud != null, "HUD node exists")


func _verify_startup_state() -> void:
	_expect(_world.map_size == Vector2i(150, 150), "World map is 150x150")
	_expect(_world.get_resource_count() > 0, "World generated resources")
	_expect(_player.world == _world, "Player is connected to the world")

	var slots: Array[Dictionary] = _player.get_inventory_slots_snapshot()
	_expect(slots.size() == _player.inventory.slot_count, "Inventory exposes all slots")
	_expect(slots.size() >= _player.inventory.toolbelt_slot_count, "Inventory has toolbelt slots")
	if not slots.is_empty():
		var first_slot: Dictionary = slots[0]
		_expect(StringName(first_slot.get("item_id", &"")) == &"multitool_cutter", "First hotbar slot contains the Multitool Cutter")
		_expect(bool(first_slot.get("locked", false)), "Multitool Cutter slot is locked")


func _verify_time_of_day_cycle() -> void:
	var original_day_length: float = _world.day_length_seconds
	var original_cycle_enabled: bool = _world.time_cycle_enabled

	_world.time_cycle_enabled = false
	_world.set_time_of_day(6.0, 1)
	_expect(_get_world_phase_id() == &"morning", "Time phase is Morning from 06:00")
	_world.set_time_of_day(8.99, 1)
	_expect(_get_world_phase_id() == &"morning", "Time phase stays Morning before 09:00")
	_world.set_time_of_day(9.0, 1)
	_expect(_get_world_phase_id() == &"day", "Time phase is Day from 09:00")
	_world.set_time_of_day(16.0, 1)
	_expect(_get_world_phase_id() == &"evening", "Time phase is Evening from 16:00")
	_world.set_time_of_day(22.0, 1)
	_expect(_get_world_phase_id() == &"night", "Time phase is Night from 22:00")
	_world.set_time_of_day(5.99, 1)
	_expect(_get_world_phase_id() == &"night", "Time phase stays Night before 06:00")

	_world.day_length_seconds = 24.0
	_world.time_cycle_enabled = true
	_world.set_time_of_day(6.0, 1)
	var minute_before: int = _get_world_time_minutes()
	_world.call("_process", 0.5)
	await process_frame
	var minute_after: int = _get_world_time_minutes()
	_expect(minute_after > minute_before, "Time of day advances dynamically")

	_world.day_length_seconds = original_day_length
	_world.time_cycle_enabled = original_cycle_enabled
	_world.set_time_of_day(6.0, 1)


func _verify_movement_and_mouse_facing() -> void:
	var start_position: Vector2 = _player.global_position
	Input.action_press(&"move_right")
	await _physics_steps(8)
	Input.action_release(&"move_right")
	await _physics_steps(2)
	_expect(_player.global_position.x > start_position.x + 1.0, "Player moves using input actions")

	var target_position: Vector2 = _player.global_position + Vector2(120.0, 0.0)
	_player.face_towards_world_position(target_position)
	_expect(_player.facing.x > 0.75, "Player faces the mouse cursor")


func _verify_inventory_window_buttons() -> void:
	await _open_inventory_with_action()
	_expect(_is_inventory_visible(), "Inventory opens with the inventory action")
	_expect(_player.gameplay_input_blocked, "Gameplay input is blocked while inventory is open")
	await _verify_ui_blocks_movement()

	await _press_button_by_text(_hud, "Inventory")
	_expect(_is_content_visible("_inventory_content"), "Inventory category button shows inventory content")
	await _press_button_by_text(_hud, "Building")
	_expect(_is_content_visible("_building_content"), "Building category button shows building content")
	await _press_button_by_text(_hud, "Upgrades")
	_expect(_is_content_visible("_upgrades_content"), "Upgrades category button shows upgrades content")
	await _press_button_by_text(_hud, "Main Menu")
	_expect(_is_content_visible("_main_menu_content"), "Main Menu category button shows main menu content")

	await _close_inventory_with_action()
	_expect(not _is_inventory_visible(), "Inventory closes with the inventory action after category clicks")
	_expect(not _player.gameplay_input_blocked, "Gameplay input unblocks after inventory closes")


func _verify_harvest_drop_pickup() -> void:
	var resource: HarvestableResourceNode = _find_first_resource()
	_expect(resource != null, "A resource node is available for harvesting")
	if resource == null:
		return

	var resource_count_before: int = _world.get_resource_count()
	var depleted_grid: Vector2i = resource.grid_position
	var drop_item_id: StringName = resource.drop_item_id
	var inventory_before: int = _player.inventory.get_count(drop_item_id)
	var ground_before: int = _count_ground_items(drop_item_id)

	_player.global_position = resource.global_position + Vector2(-28.0, 0.0)
	await _warp_mouse_to_global(resource.global_position)
	_player.facing = Vector2.RIGHT
	_player.call("_try_start_cutter_lock")
	await process_frame
	_expect(_player.get("_cutter_target") == resource, "Multitool Cutter locks on to the resource")

	var health_after_lock: float = resource.health
	_player.call("_update_cutter_lock", 0.25)
	await process_frame
	_expect(resource.health < health_after_lock, "Multitool Cutter deals gradual damage while locked")

	await _warp_mouse_to_global(_player.global_position + Vector2(0.0, 80.0))
	_player.call("_update_mouse_facing")
	_player.call("_update_cutter_lock", 0.1)
	await process_frame
	_expect(_player.facing.y > 0.70, "Multitool Cutter beam can be steered while active")

	await _warp_mouse_to_global(resource.global_position)
	_player.call("_update_mouse_facing")
	var position_before_moving_cut: Vector2 = _player.global_position
	Input.action_press(&"move_down")
	await _physics_steps(4)
	Input.action_release(&"move_down")
	await _physics_steps(1)
	_expect(_player.global_position.y > position_before_moving_cut.y + 1.0, "Player can move while the Multitool Cutter is active")

	var health_after_moving: float = resource.health
	_player.face_towards_world_position(resource.global_position)
	_player.call("_update_cutter_lock", 0.25)
	await process_frame
	_expect(resource.health < health_after_moving, "Multitool Cutter keeps damaging after moving when aimed at the target")

	var cutter_steps: int = ceili(resource.max_health / _player.cutter_damage_per_second * 6.0) + 4
	for step_index: int in range(cutter_steps):
		if not is_instance_valid(resource) or resource.is_queued_for_deletion():
			break
		_player.face_towards_world_position(resource.global_position)
		_player.call("_update_cutter_lock", 0.2)
		await process_frame

	_expect(_count_ground_items(drop_item_id) > ground_before, "Harvesting drops items on the ground")
	_expect(_world.can_place_building(&"fence", depleted_grid), "Depleted resource cells become buildable")
	_expect(_world.get_resource_count() == resource_count_before - 1, "Resource count decrements when a resource depletes")

	var ground_item: Node2D = _find_ground_item(drop_item_id)
	_expect(ground_item != null, "Harvested ground item can be found")
	if ground_item != null:
		_player.global_position = ground_item.global_position
		_player.set("_pickup_left", 0.0)
		_player.call("_try_pickup_ground_items")
		await process_frame
		await physics_frame
		_expect(_player.inventory.get_count(drop_item_id) > inventory_before, "Player picks up ground items by proximity")


func _verify_building_buttons_and_placement() -> void:
	_player.global_position = _world.get_spawn_position()
	await _physics_steps(2)
	await _add_inventory_items({
		&"wood": 80,
		&"stone": 80,
		&"ore": 30,
	})
	_expect(not _world.can_place_building(&"fence", _world.world_to_grid(_player.global_position)), "Buildings cannot be placed on the player")
	await _verify_failed_building_placement_rolls_back_cost()

	var furnace_grid: Vector2i = await _place_building_from_ui(&"furnace")
	_expect(_find_building_at(&"furnace", furnace_grid) != null, "Furnace is placed from the Building UI")

	var forge_grid: Vector2i = await _place_building_from_ui(&"forge")
	_expect(_find_building_at(&"forge", forge_grid) != null, "Forge is placed from the Building UI")

	var workbench_grid: Vector2i = await _place_building_from_ui(&"workbench")
	_expect(_find_building_at(&"workbench", workbench_grid) != null, "Workbench is placed from the Building UI")


func _verify_failed_building_placement_rolls_back_cost() -> void:
	var building_id: StringName = &"furnace"
	var grid_position: Vector2i = _find_free_grid_near_player(building_id)
	_expect(grid_position.x > -9000, "Found free placement grid for failed Furnace placement")
	if grid_position.x <= -9000:
		return

	var wood_before: int = _player.inventory.get_count(&"wood")
	var stone_before: int = _player.inventory.get_count(&"stone")
	var furnace_before: BuildingInstance = _find_building_at(building_id, grid_position)
	_expect(furnace_before == null, "Rollback check grid starts empty")

	var original_world: Node = _player.world
	var failed_world: FailedPlacementWorld = FailedPlacementWorld.new(_world)
	_main.add_child(failed_world)
	_player.set_world(failed_world)
	_player.start_building_placement(building_id)
	_expect(_player.pending_building_id == building_id, "Furnace placement mode starts for rollback check")

	var placed: bool = _player.try_place_pending_building_at_grid(grid_position)
	await process_frame
	await physics_frame

	_player.set_world(original_world)
	_player.cancel_building_placement()
	failed_world.queue_free()
	await process_frame

	_expect(not placed, "Failed Furnace placement reports failure")
	_expect(_find_building_at(building_id, grid_position) == null, "Failed Furnace placement does not create a building")
	_expect(_player.inventory.get_count(&"wood") == wood_before, "Failed Furnace placement refunds wood")
	_expect(_player.inventory.get_count(&"stone") == stone_before, "Failed Furnace placement refunds stone")


func _verify_station_buttons_crafting_and_pickup() -> void:
	var furnace: BuildingInstance = _find_first_building(&"furnace")
	var forge: BuildingInstance = _find_first_building(&"forge")
	var workbench: BuildingInstance = _find_first_building(&"workbench")
	_expect(furnace != null, "Furnace exists for station checks")
	_expect(forge != null, "Forge exists for station checks")
	_expect(workbench != null, "Workbench exists for station checks")
	if furnace == null or forge == null or workbench == null:
		return

	await _craft_recipe_and_pickup(furnace, "Coal", &"coal", 1)
	await _craft_recipe_and_pickup(furnace, "Iron Ingot", &"iron_ingot", 1)
	await _add_inventory_items({&"iron_ingot": 9})
	await _craft_recipe_and_pickup(forge, "Iron Armor", &"iron_armor", 1)
	await _craft_recipe_and_pickup(workbench, "Fence", &"fence", 1)

	var fence_grid: Vector2i = await _place_building_from_ui(&"fence")
	_expect(_find_building_at(&"fence", fence_grid) != null, "Crafted fence item can be placed from the Building UI")


func _verify_station_auto_close() -> void:
	var furnace: BuildingInstance = _find_first_building(&"furnace")
	_expect(furnace != null, "Furnace exists for station auto-close check")
	if furnace == null:
		return

	await _verify_inventory_toggle_closes_station(furnace)

	await _open_station(furnace)
	_expect(_is_station_visible(), "Station window is visible before range check")
	_player.global_position = furnace.global_position + Vector2(_player.station_interact_range + 180.0, 0.0)
	await _physics_steps(4)
	_expect(_player.active_station == null, "Station interaction auto-closes when player leaves range")
	_expect(not _is_station_visible(), "Station UI hides after auto-close")


func _verify_ui_blocks_movement() -> void:
	var position_before: Vector2 = _player.global_position
	Input.action_press(&"move_right")
	await _physics_steps(8)
	Input.action_release(&"move_right")
	await _physics_steps(2)
	_expect(_player.global_position.distance_to(position_before) < 1.0, "Open UI blocks player movement")


func _verify_inventory_toggle_closes_station(station: BuildingInstance) -> void:
	await _open_station(station)
	_expect(_is_station_visible(), "Station window is visible before inventory toggle")
	await _tap_action(&"inventory")
	await process_frame
	_expect(not _is_station_visible(), "Inventory toggle closes station UI first")
	_expect(_is_inventory_visible(), "Inventory opens after station UI closes")
	await _close_inventory_with_action()


func _verify_building_occupancy_release() -> void:
	var fence: BuildingInstance = _find_first_building(&"fence")
	_expect(fence != null, "Fence exists for occupancy release check")
	if fence == null:
		return

	var grid_position: Vector2i = fence.grid_position
	fence.queue_free()
	await process_frame
	await process_frame
	_expect(_world.can_place_building(&"fence", grid_position), "Building cells are released when a building leaves the tree")


func _craft_recipe_and_pickup(station: BuildingInstance, recipe_title: String, output_item_id: StringName, output_amount: int) -> void:
	await _open_station(station)
	var inventory_before: int = _player.inventory.get_count(output_item_id)
	var ground_before: int = _count_ground_items(output_item_id)
	await _press_station_recipe_button(recipe_title)
	_expect(station.is_crafting(), "%s recipe starts crafting" % recipe_title)

	station.call("_process", 10.5)
	await process_frame
	await physics_frame
	_expect(not station.is_crafting(), "%s recipe completes" % recipe_title)
	_expect(_count_ground_items(output_item_id) >= ground_before + output_amount, "%s output drops on the ground" % recipe_title)
	_expect(_player.inventory.get_count(output_item_id) == inventory_before, "%s output waits on the ground before pickup" % recipe_title)

	var output_item: Node2D = _find_ground_item(output_item_id)
	_expect(output_item != null, "%s ground output exists" % recipe_title)
	if output_item != null:
		_expect(not _is_point_inside_building_footprint(station, output_item.global_position), "%s output drops outside the station footprint" % recipe_title)
		_player.global_position = output_item.global_position
		_player.set("_pickup_left", 0.0)
		_player.call("_try_pickup_ground_items")
		await process_frame
		await physics_frame
		_expect(_player.inventory.get_count(output_item_id) >= inventory_before + output_amount, "%s output can be picked up" % recipe_title)

	await _open_station(station)
	await _press_button_by_text(_hud, "Close")
	_expect(not _is_station_visible(), "Station Close button hides the station UI")


func _open_station(station: BuildingInstance) -> void:
	_player.close_station_ui()
	await process_frame
	var station_offset: Vector2 = Vector2(-90.0, 0.0)
	_player.global_position = station.global_position + station_offset
	var opened: bool = _player.try_open_station_at_world_position(station.global_position)
	_expect(opened, "Station opens while cursor points at a nearby station")
	await process_frame
	_expect(_player.active_station == station, "Player tracks the active station")
	_expect(_is_station_visible(), "Station UI is visible")


func _place_building_from_ui(building_id: StringName) -> Vector2i:
	var grid_position: Vector2i = _find_free_grid_near_player(building_id)
	_expect(grid_position.x > -9000, "Found free placement grid for %s" % String(building_id))
	if grid_position.x <= -9000:
		return grid_position

	var name: String = String(BUILDING_NAMES.get(building_id, String(building_id)))
	await _press_building_create_button(name)
	_expect(_player.pending_building_id == building_id, "%s placement mode starts from UI button" % name)

	var placed: bool = _player.try_place_pending_building_at_grid(grid_position)
	await process_frame
	await physics_frame
	_expect(placed, "%s placement succeeds through the player placement flow" % name)
	_expect(_player.pending_building_id == &"", "%s placement mode ends after successful placement" % name)
	return grid_position


func _press_building_create_button(building_name: String) -> void:
	await _open_inventory_with_action()
	await _press_button_by_text(_hud, "Building")
	var label: Label = _find_label_by_text(_hud, building_name)
	_expect(label != null, "%s building slot label exists" % building_name)
	if label == null:
		return

	var slot_root: Node = label.get_parent()
	var create_button: Button = _find_button_by_text(slot_root, "Create")
	_expect(create_button != null, "%s Create button exists" % building_name)
	if create_button == null:
		return

	await _press_button(create_button, "Create %s" % building_name)


func _press_station_recipe_button(recipe_title: String) -> void:
	var label: Label = _find_label_by_text(_hud, recipe_title)
	_expect(label != null, "%s recipe label exists" % recipe_title)
	if label == null:
		return

	var node: Node = label
	while node != null:
		var craft_button: Button = _find_button_by_text(node, "Craft")
		if craft_button != null:
			_expect(not craft_button.disabled, "%s Craft button is enabled" % recipe_title)
			await _press_button(craft_button, "Craft %s" % recipe_title)
			return
		node = node.get_parent()

	_expect(false, "%s Craft button exists" % recipe_title)


func _open_inventory_with_action() -> void:
	if _is_inventory_visible():
		return
	await _tap_action(&"inventory")
	await process_frame


func _close_inventory_with_action() -> void:
	if not _is_inventory_visible():
		return
	await _tap_action(&"inventory")
	await process_frame


func _tap_action(action: StringName) -> void:
	var press_event: InputEventAction = InputEventAction.new()
	press_event.action = action
	press_event.pressed = true
	press_event.strength = 1.0
	Input.parse_input_event(press_event)
	await process_frame

	var release_event: InputEventAction = InputEventAction.new()
	release_event.action = action
	release_event.pressed = false
	release_event.strength = 0.0
	Input.parse_input_event(release_event)
	await process_frame


func _press_button_by_text(parent: Node, text: String) -> void:
	var button: Button = _find_button_by_text(parent, text)
	_expect(button != null, "%s button exists" % text)
	if button == null:
		return
	await _press_button(button, text)


func _press_button(button: Button, label: String) -> void:
	_expect(button.is_inside_tree(), "%s button is inside the tree" % label)
	_expect(not button.disabled, "%s button is enabled" % label)
	if button.disabled:
		return

	_pressed_buttons.append(label)
	button.emit_signal("pressed")
	await process_frame
	await physics_frame


func _is_inventory_visible() -> bool:
	var window: Control = _hud.get("_inventory_window") as Control
	return window != null and window.visible


func _is_station_visible() -> bool:
	var window: Control = _hud.get("_station_window") as Control
	return window != null and window.visible


func _is_content_visible(property_name: String) -> bool:
	var content: Control = _hud.get(property_name) as Control
	return content != null and content.visible


func _add_inventory_items(items: Dictionary) -> void:
	for item_id_value: Variant in items.keys():
		var item_id: StringName = StringName(item_id_value)
		var amount: int = int(items[item_id_value])
		var leftover: int = _player.inventory.add_item_with_leftover(item_id, amount)
		_expect(leftover == 0, "Inventory accepts %s x%d" % [String(item_id), amount])
	await process_frame


func _find_free_grid_near_player(building_id: StringName) -> Vector2i:
	var player_grid: Vector2i = _world.world_to_grid(_player.global_position)
	var definition: Dictionary = _world.get_building_definition(building_id)
	var footprint: Vector2i = definition.get("footprint", Vector2i.ONE) as Vector2i

	for radius: int in range(1, 6):
		for x_offset: int in range(-radius, radius + 1):
			for y_offset: int in range(-radius, radius + 1):
				var grid_position: Vector2i = player_grid + Vector2i(x_offset, y_offset)
				var center: Vector2 = _world.grid_to_world_center(grid_position, footprint)
				if center.distance_to(_player.global_position) < 48.0:
					continue
				if center.distance_to(_player.global_position) > _player.build_range:
					continue
				if _world.can_place_building(building_id, grid_position):
					return grid_position

	return Vector2i(-9999, -9999)


func _find_first_resource() -> HarvestableResourceNode:
	for node: Node in get_nodes_in_group("resource_nodes"):
		if not is_instance_valid(node):
			continue
		if node.is_queued_for_deletion():
			continue
		if node is HarvestableResourceNode:
			return node as HarvestableResourceNode
	return null


func _find_first_building(building_id: StringName) -> BuildingInstance:
	for node: Node in get_nodes_in_group("buildings"):
		if not is_instance_valid(node):
			continue
		if node.is_queued_for_deletion():
			continue
		if not node is BuildingInstance:
			continue
		var building: BuildingInstance = node as BuildingInstance
		if building.building_id == building_id:
			return building
	return null


func _find_building_at(building_id: StringName, grid_position: Vector2i) -> BuildingInstance:
	for node: Node in get_nodes_in_group("buildings"):
		if not is_instance_valid(node):
			continue
		if node.is_queued_for_deletion():
			continue
		if not node is BuildingInstance:
			continue
		var building: BuildingInstance = node as BuildingInstance
		if building.building_id == building_id and building.grid_position == grid_position:
			return building
	return null


func _count_ground_items(item_id: StringName) -> int:
	var count: int = 0
	for node: Node in get_nodes_in_group("ground_items"):
		if not is_instance_valid(node):
			continue
		if node.is_queued_for_deletion():
			continue
		if StringName(node.get("item_id")) == item_id:
			count += int(node.get("amount"))
	return count


func _find_ground_item(item_id: StringName) -> Node2D:
	var best_item: Node2D = null
	var best_score: float = INF
	for node: Node in get_nodes_in_group("ground_items"):
		if not is_instance_valid(node):
			continue
		if node.is_queued_for_deletion():
			continue
		if not node is Node2D:
			continue
		if StringName(node.get("item_id")) != item_id:
			continue

		var item: Node2D = node as Node2D
		var score: float = _player.global_position.distance_squared_to(item.global_position)
		if score < best_score:
			best_score = score
			best_item = item
	return best_item


func _is_point_inside_building_footprint(building: BuildingInstance, point: Vector2) -> bool:
	var size: Vector2 = Vector2(float(building.footprint.x * building.tile_size), float(building.footprint.y * building.tile_size))
	var rect: Rect2 = Rect2(building.global_position - size * 0.5, size)
	return rect.has_point(point)


func _get_world_phase_id() -> StringName:
	var snapshot: Dictionary = _world.get_time_of_day_snapshot()
	return StringName(snapshot.get("phase_id", &""))


func _get_world_time_minutes() -> int:
	var snapshot: Dictionary = _world.get_time_of_day_snapshot()
	return int(snapshot.get("hour", 0)) * 60 + int(snapshot.get("minute", 0))


func _find_button_by_text(parent: Node, text: String) -> Button:
	if parent is Button:
		var button: Button = parent as Button
		if button.text == text:
			return button

	for child: Node in parent.get_children():
		var found: Button = _find_button_by_text(child, text)
		if found != null:
			return found
	return null


func _find_label_by_text(parent: Node, text: String) -> Label:
	if parent is Label:
		var label: Label = parent as Label
		if label.text == text:
			return label

	for child: Node in parent.get_children():
		var found: Label = _find_label_by_text(child, text)
		if found != null:
			return found
	return null


func _warp_mouse_to_global(world_position: Vector2) -> void:
	var world_canvas: CanvasItem = _world as CanvasItem
	var viewport_position: Vector2 = world_canvas.get_global_transform_with_canvas() * world_canvas.to_local(world_position)
	root.warp_mouse(viewport_position)
	var motion_event: InputEventMouseMotion = InputEventMouseMotion.new()
	motion_event.position = viewport_position
	motion_event.global_position = viewport_position
	root.push_input(motion_event)
	Input.parse_input_event(motion_event)
	await process_frame


func _physics_steps(count: int) -> void:
	for step_index: int in range(count):
		await physics_frame


func _expect(condition: bool, message: String) -> void:
	if condition:
		print("[smoke] OK: %s" % message)
		return

	var failure: String = "[smoke] FAIL: %s" % message
	push_error(failure)
	_failures.append(failure)


func _finish() -> void:
	if _failures.is_empty():
		print("[smoke] Passed. UI buttons pressed: %s" % ", ".join(_pressed_buttons))
		quit(0)
		return

	print("[smoke] Failed with %d issue(s)" % _failures.size())
	for failure: String in _failures:
		print(failure)
	quit(1)
