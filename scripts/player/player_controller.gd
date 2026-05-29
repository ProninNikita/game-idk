extends CharacterBody2D
class_name PlayerController

signal inventory_changed(items: Dictionary)
signal inventory_slots_changed(slots: Array)
signal action_hint_changed(text: String)
signal station_opened(snapshot: Dictionary)
signal station_updated(snapshot: Dictionary)
signal station_closed()

@export var move_speed: float = 220.0
@export var cutter_lock_range: float = 62.0
@export var cutter_damage_per_second: float = 2.0
@export var pickup_radius: float = 34.0
@export var pickup_interval: float = 0.12
@export var build_range: float = 128.0
@export var station_interact_range: float = 112.0

@onready var inventory: InventoryComponent = $Inventory
@onready var camera: Camera2D = $Camera2D

const DataRegistry = preload("res://scripts/data/data_registry.gd")
const CUTTER_TOOL_TAGS: Array[StringName] = [&"cutting", &"harvesting", &"combat"]
const CUTTER_LOCK_MIN_DOT: float = 0.72
const CUTTER_LOCK_PADDING: float = 8.0
const MODE_NORMAL: StringName = &"normal"
const MODE_INVENTORY: StringName = &"inventory"
const MODE_STATION: StringName = &"station"
const MODE_BUILDING: StringName = &"building_placement"
const MODE_PAUSE: StringName = &"pause"

var world_bounds: Rect2 = Rect2()
var facing: Vector2 = Vector2.DOWN
var world: HearthlineWorld = null
var pending_building_id: StringName = &""
var active_station: BuildingInstance = null
var gameplay_input_blocked: bool = false
var gameplay_mode: StringName = MODE_NORMAL
var _cutter_active: bool = false
var _cutter_target: Node2D = null
var _last_hint_time: float = 0.0
var _pickup_left: float = 0.0
var _station_update_left: float = 0.0


func _ready() -> void:
	add_to_group("player")
	inventory.changed.connect(_on_inventory_changed)
	queue_redraw()


func _physics_process(delta: float) -> void:
	_last_hint_time = max(0.0, _last_hint_time - delta)
	_pickup_left = max(0.0, _pickup_left - delta)
	_station_update_left = max(0.0, _station_update_left - delta)

	var input_vector: Vector2 = Vector2.ZERO
	if not gameplay_input_blocked:
		input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed

	_update_mouse_facing()

	move_and_slide()
	_clamp_to_world()

	if not gameplay_input_blocked and _pickup_left <= 0.0:
		_pickup_left = pickup_interval
		_try_pickup_ground_items()

	var attack_pressed: bool = Input.is_action_just_pressed("attack") and not gameplay_input_blocked and not _is_mouse_over_ui()
	var interact_pressed: bool = Input.is_action_just_pressed("interact") and not gameplay_input_blocked
	var handled_discrete_action: bool = false

	if pending_building_id != &"" and attack_pressed:
		_try_place_pending_building()
		handled_discrete_action = true
	elif interact_pressed:
		handled_discrete_action = _try_open_station()

	if pending_building_id != &"" and Input.is_action_just_pressed("ui_cancel"):
		cancel_building_placement()

	if pending_building_id != &"" or handled_discrete_action:
		_clear_cutter_lock(false)
	else:
		var cutter_requested: bool = _is_cutter_input_held()
		_update_cutter_lock(delta, cutter_requested)
		if (attack_pressed or (interact_pressed and not handled_discrete_action)) and not _cutter_active:
			_emit_temporary_hint("Aim the cutter at a target")

	if active_station != null:
		if not _is_active_station_available():
			close_station_ui()
		elif _station_update_left <= 0.0:
			_station_update_left = 0.15
			_refresh_active_station_ui()


func set_world(new_world: HearthlineWorld) -> void:
	if world != null:
		world.unregister_dynamic_placement_blocker(self)
	world = new_world
	if world != null:
		world.register_dynamic_placement_blocker(self)


func set_world_bounds(bounds: Rect2) -> void:
	world_bounds = bounds
	if camera != null:
		camera.limit_left = int(bounds.position.x)
		camera.limit_top = int(bounds.position.y)
		camera.limit_right = int(bounds.end.x)
		camera.limit_bottom = int(bounds.end.y)


func get_inventory_snapshot() -> Dictionary:
	return inventory.get_items()


func get_inventory_slots_snapshot() -> Array[Dictionary]:
	return inventory.get_slots()


func set_gameplay_input_blocked(blocked: bool) -> void:
	if blocked:
		if gameplay_mode == MODE_NORMAL:
			set_gameplay_mode(MODE_INVENTORY)
	else:
		if gameplay_mode == MODE_INVENTORY or gameplay_mode == MODE_PAUSE:
			set_gameplay_mode(MODE_NORMAL)
		else:
			gameplay_input_blocked = _does_mode_block_gameplay_input(gameplay_mode)


func set_gameplay_mode(new_mode: StringName) -> void:
	gameplay_mode = new_mode
	gameplay_input_blocked = _does_mode_block_gameplay_input(gameplay_mode)
	if gameplay_mode != MODE_BUILDING and pending_building_id != &"":
		pending_building_id = &""
	queue_redraw()


func _does_mode_block_gameplay_input(mode: StringName) -> bool:
	return mode == MODE_INVENTORY or mode == MODE_STATION or mode == MODE_PAUSE


func face_towards_world_position(target_position: Vector2) -> void:
	var to_target: Vector2 = target_position - global_position
	if to_target.length_squared() <= 4.0:
		return

	facing = to_target.normalized()
	queue_redraw()


func start_building_placement(building_id: StringName) -> void:
	if world == null:
		_emit_temporary_hint("World is not ready")
		return

	var definition: Dictionary = world.get_building_definition(building_id)
	if definition.is_empty():
		_emit_temporary_hint("Unknown building")
		return
	if not DataRegistry.has_building_cost(building_id):
		_emit_temporary_hint("Missing building cost definition")
		return
	if not _has_building_cost(building_id):
		_emit_temporary_hint("Need %s" % _format_building_cost(building_id))
		return

	pending_building_id = building_id
	set_gameplay_mode(MODE_BUILDING)
	_clear_cutter_lock(false)
	_emit_temporary_hint("Place %s near the player. Left click to build, Esc to cancel." % String(definition.get("display_name", building_id)))
	queue_redraw()


func cancel_building_placement() -> void:
	pending_building_id = &""
	if gameplay_mode == MODE_BUILDING:
		set_gameplay_mode(MODE_NORMAL)
	_emit_temporary_hint("Building placement canceled")
	queue_redraw()


func close_station_ui() -> void:
	active_station = null
	if gameplay_mode == MODE_STATION:
		set_gameplay_mode(MODE_NORMAL)
	station_closed.emit()


func load_station_recipe_inputs(recipe_id: StringName) -> void:
	if not _is_active_station_available():
		close_station_ui()
		_emit_temporary_hint("No station in range")
		return

	var recipe: Dictionary = active_station.get_recipe(recipe_id)
	if recipe.is_empty():
		_emit_temporary_hint("Unknown recipe")
		_refresh_active_station_ui()
		return

	var missing: Dictionary = active_station.get_missing_recipe_inputs(recipe_id)
	if missing.is_empty():
		_emit_temporary_hint("Inputs already loaded")
		_refresh_active_station_ui()
		return
	if not active_station.can_accept_input_items(missing):
		_emit_temporary_hint("Station input full")
		_refresh_active_station_ui()
		return
	if not inventory.can_remove_items(missing):
		_emit_temporary_hint("Need %s" % _format_cost(missing))
		_refresh_active_station_ui()
		return
	if not inventory.try_remove_items(missing):
		_emit_temporary_hint("Need %s" % _format_cost(missing))
		_refresh_active_station_ui()
		return

	var leftover: Dictionary = active_station.add_input_items(missing)
	if not leftover.is_empty():
		_refund_cost(leftover)
		_emit_temporary_hint("Station input full")
	else:
		_emit_temporary_hint("Loaded %s" % String(recipe.get("display_name", "recipe")))
	inventory_slots_changed.emit(inventory.get_slots())
	_refresh_active_station_ui()


func collect_active_station_outputs() -> void:
	if not _is_active_station_available():
		close_station_ui()
		_emit_temporary_hint("No station in range")
		return

	var collected: Dictionary = active_station.collect_outputs_to_inventory(inventory)
	if collected.is_empty():
		_emit_temporary_hint("No station outputs to collect")
	else:
		_emit_temporary_hint("Collected %s" % _format_cost(collected))
	inventory_slots_changed.emit(inventory.get_slots())
	_refresh_active_station_ui()


func start_station_recipe(recipe_id: StringName) -> void:
	if not _is_active_station_available():
		close_station_ui()
		_emit_temporary_hint("No station in range")
		return
	if active_station.is_crafting():
		_emit_temporary_hint("%s is already crafting" % active_station.display_name)
		_refresh_active_station_ui()
		return

	var recipe: Dictionary = active_station.get_recipe(recipe_id)
	if recipe.is_empty():
		_emit_temporary_hint("Unknown recipe")
		_refresh_active_station_ui()
		return
	if not active_station.has_recipe_inputs(recipe_id):
		_emit_temporary_hint("Load station inputs: %s" % _format_recipe_inputs(recipe))
		_refresh_active_station_ui()
		return
	var started: bool = active_station.start_craft(recipe_id)
	if not started:
		_emit_temporary_hint(active_station.get_station_state_label())
		_refresh_active_station_ui()
		return

	_emit_temporary_hint("Crafting %s" % String(recipe.get("display_name", "item")))
	_refresh_active_station_ui()


func _try_harvest() -> void:
	_try_start_cutter_lock()


func _try_start_cutter_lock() -> void:
	_update_cutter_lock(0.0, true)
	if not _cutter_active:
		_emit_temporary_hint("Aim the cutter at a target")


func _update_cutter_lock(delta: float, cutter_requested: bool = true) -> void:
	if not cutter_requested:
		_clear_cutter_lock(false)
		return
	if gameplay_input_blocked:
		_clear_cutter_lock(false)
		return

	var target: Node2D = _find_cutter_target()
	if target == null and _is_cutter_target_available(_cutter_target):
		target = _cutter_target
	if target == null:
		_clear_cutter_lock(false)
		return

	var target_changed: bool = target != _cutter_target
	_cutter_active = true
	_cutter_target = target
	if target_changed:
		_emit_temporary_hint("Cutter locked: %s" % _get_target_display_name(target))

	var drop: Dictionary = target.call("hit", cutter_damage_per_second * delta, CUTTER_TOOL_TAGS) as Dictionary
	if drop.has("item_id"):
		var item_id: StringName = StringName(drop["item_id"])
		var amount: int = int(drop.get("amount", 1))
		var drop_position: Vector2 = drop.get("position", target.global_position) as Vector2
		var drop_color: Color = drop.get("color", Color(0.92, 0.78, 0.28)) as Color
		if world != null:
			world.spawn_ground_item(item_id, amount, drop_position, drop_color)
		_emit_temporary_hint("Cutter extracted %s x%d" % [String(item_id), amount])
		_clear_cutter_lock(false)
		return

	if not is_instance_valid(target) or target.is_queued_for_deletion():
		_clear_cutter_lock(false)
		return

	queue_redraw()


func _is_cutter_input_held() -> bool:
	if gameplay_input_blocked:
		return false

	var attack_held: bool = Input.is_action_pressed("attack") and not _is_mouse_over_ui()
	var interact_held: bool = Input.is_action_pressed("interact")
	return attack_held or interact_held


func _try_place_pending_building() -> void:
	if pending_building_id == &"":
		return
	if world == null:
		return

	var grid_position: Vector2i = _get_pending_build_grid_position()
	try_place_pending_building_at_grid(grid_position)


func try_place_pending_building_at_grid(grid_position: Vector2i) -> bool:
	if pending_building_id == &"":
		return false
	if world == null:
		return false

	var transaction: Dictionary = _build_pending_building_transaction(grid_position)
	if not bool(transaction.get("valid", false)):
		_emit_building_transaction_failure(transaction)
		return false

	var building_id: StringName = StringName(transaction.get("building_id", &""))
	var cost: Dictionary = transaction.get("cost", {}) as Dictionary
	if not inventory.try_remove_items(cost):
		_emit_temporary_hint("Need %s" % _format_cost(cost))
		return false

	var placement_check: Dictionary = _validate_building_placement(building_id, grid_position, false)
	if not bool(placement_check.get("valid", false)):
		_refund_cost(cost)
		_emit_building_transaction_failure(placement_check)
		return false

	var placed: bool = world.place_building(building_id, grid_position)
	if not placed:
		_refund_cost(cost)
		_emit_temporary_hint("Cannot build there")
		return false

	var display_name: String = String(transaction.get("display_name", String(building_id)))
	_emit_temporary_hint("Built %s" % display_name)
	pending_building_id = &""
	if gameplay_mode == MODE_BUILDING:
		set_gameplay_mode(MODE_NORMAL)
	queue_redraw()
	return true


func _try_open_station() -> bool:
	return try_open_station_at_world_position(get_global_mouse_position())


func try_open_station_at_world_position(target_position: Vector2) -> bool:
	var station: BuildingInstance = _find_station_target_at_point(target_position)
	if station == null:
		return false

	_clear_cutter_lock(false)
	active_station = station
	_ensure_station_connected(station)
	set_gameplay_mode(MODE_STATION)
	station_opened.emit(_build_station_snapshot(station))
	_emit_temporary_hint("Opened %s" % station.display_name)
	return true


func _find_station_target() -> BuildingInstance:
	return _find_station_target_at_point(get_global_mouse_position())


func _find_station_target_at_point(target_position: Vector2) -> BuildingInstance:
	if world == null:
		return null
	return world.find_station_at_point(target_position, global_position, station_interact_range)


func _find_resource_target() -> HarvestableResourceNode:
	return _find_cutter_target() as HarvestableResourceNode


func _find_cutter_target() -> Node2D:
	var best_target: Node2D = null
	var best_score: float = INF
	var beam_end: Vector2 = _get_cutter_beam_end_world()
	var aim_vector: Vector2 = beam_end - global_position
	var beam_length: float = aim_vector.length()
	if beam_length <= 0.01:
		return null
	var aim_direction: Vector2 = aim_vector / beam_length
	if world == null:
		return null

	for target: Node2D in world.get_cutter_targets():
		if not target.has_method("hit"):
			continue

		var to_target: Vector2 = target.global_position - global_position
		var distance: float = to_target.length()
		if distance <= 0.01:
			continue
		if distance > cutter_lock_range:
			continue

		var direction_score: float = aim_direction.dot(to_target / distance)
		if direction_score < CUTTER_LOCK_MIN_DOT:
			continue

		var target_radius: float = _get_target_lock_radius(target)
		var perpendicular_distance: float = absf(aim_direction.cross(to_target))
		if perpendicular_distance > target_radius + CUTTER_LOCK_PADDING:
			continue

		var score: float = perpendicular_distance * 3.0 + distance * 0.05 - direction_score
		if score < best_score:
			best_score = score
			best_target = target

	return best_target


func _is_cutter_target_available(target: Variant) -> bool:
	if target == null:
		return false
	if not is_instance_valid(target):
		return false
	if not (target is Node2D):
		return false
	var target_node: Node2D = target as Node2D
	if target_node.is_queued_for_deletion():
		return false
	if not target_node.is_inside_tree():
		return false
	if not target_node.has_method("hit"):
		return false
	return global_position.distance_to(target_node.global_position) <= cutter_lock_range


func _clear_cutter_lock(show_hint: bool = true) -> void:
	if not _cutter_active and _cutter_target == null:
		return

	_cutter_active = false
	_cutter_target = null
	if show_hint:
		_emit_temporary_hint("Cutter lock released")
	queue_redraw()


func _get_target_display_name(target: Node) -> String:
	var display_name_value: Variant = target.get("display_name")
	if display_name_value != null and String(display_name_value) != "":
		return String(display_name_value)
	return target.name


func _get_target_lock_radius(target: Node) -> float:
	var radius_value: Variant = target.get("collision_radius")
	if radius_value != null:
		return float(radius_value)
	return 12.0


func _get_cutter_beam_end_world() -> Vector2:
	var direction: Vector2 = facing
	if direction.length_squared() <= 0.01:
		direction = Vector2.DOWN
	return global_position + direction.normalized() * cutter_lock_range


func _clamp_to_world() -> void:
	if world_bounds.size == Vector2.ZERO:
		return

	var margin: float = 12.0
	global_position.x = clampf(global_position.x, world_bounds.position.x + margin, world_bounds.end.x - margin)
	global_position.y = clampf(global_position.y, world_bounds.position.y + margin, world_bounds.end.y - margin)


func _update_mouse_facing() -> void:
	face_towards_world_position(get_global_mouse_position())


func _try_pickup_ground_items() -> void:
	if world == null:
		return

	var candidates: Array[GroundItem] = world.get_ground_items_near(global_position, pickup_radius)

	candidates.sort_custom(_sort_ground_items_by_distance)

	var picked_any: bool = false
	var inventory_full: bool = false

	for item: GroundItem in candidates:
		if not is_instance_valid(item):
			continue

		var item_id: StringName = StringName(item.get("item_id"))
		var amount: int = int(item.get("amount"))
		var acceptable: int = inventory.get_acceptable_amount(item_id, amount)
		if acceptable <= 0:
			inventory_full = true
			continue

		var taken: int = int(item.call("take", acceptable))
		if taken <= 0:
			continue

		var leftover: int = inventory.add_item_with_leftover(item_id, taken)
		if leftover > 0:
			if world != null:
				var item_color: Color = item.get("debug_color") as Color
				world.spawn_ground_item(item_id, leftover, item.global_position, item_color)
			inventory_full = true

		picked_any = true

	if picked_any:
		_emit_temporary_hint("Picked up items")
	elif inventory_full:
		_emit_temporary_hint("Inventory full")


func _sort_ground_items_by_distance(a: Node2D, b: Node2D) -> bool:
	return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)


func _is_mouse_over_ui() -> bool:
	return get_viewport().gui_get_hovered_control() != null


func _on_inventory_changed(items: Dictionary) -> void:
	inventory_changed.emit(items)
	inventory_slots_changed.emit(inventory.get_slots())


func _ensure_station_connected(station: BuildingInstance) -> void:
	var completed_callable: Callable = Callable(self, "_on_station_craft_completed")
	if not station.craft_completed.is_connected(completed_callable):
		station.craft_completed.connect(completed_callable)

	var changed_callable: Callable = Callable(self, "_on_station_crafting_changed")
	if not station.crafting_changed.is_connected(changed_callable):
		station.crafting_changed.connect(changed_callable)


func _is_active_station_available() -> bool:
	if active_station == null:
		return false
	if not is_instance_valid(active_station):
		return false
	if active_station.is_queued_for_deletion():
		return false
	if not active_station.is_inside_tree():
		return false
	if not active_station.has_station_recipes():
		return false

	return global_position.distance_to(active_station.global_position) <= station_interact_range


func _refresh_active_station_ui() -> void:
	if not _is_active_station_available():
		close_station_ui()
		return

	station_updated.emit(_build_station_snapshot(active_station))


func _build_station_snapshot(station: BuildingInstance) -> Dictionary:
	var snapshot: Dictionary = station.get_station_snapshot()
	var recipes: Array = snapshot.get("recipes", []) as Array
	var enhanced_recipes: Array = []
	var active_recipe_id: StringName = StringName(snapshot.get("active_recipe_id", &""))

	for recipe_value: Variant in recipes:
		var recipe: Dictionary = recipe_value as Dictionary
		var recipe_copy: Dictionary = recipe.duplicate(true)
		var recipe_id: StringName = StringName(recipe_copy.get("id", &""))
		var missing_inputs: Dictionary = station.get_missing_recipe_inputs(recipe_id)
		recipe_copy["missing_inputs"] = missing_inputs
		recipe_copy["can_load_inputs"] = not missing_inputs.is_empty() and inventory.can_remove_items(missing_inputs) and station.can_accept_input_items(missing_inputs)
		recipe_copy["can_start"] = station.has_recipe_inputs(recipe_id) and station.can_store_recipe_outputs(recipe_id)
		recipe_copy["can_afford"] = bool(recipe_copy["can_start"])
		recipe_copy["is_active"] = recipe_id == active_recipe_id
		enhanced_recipes.append(recipe_copy)

	snapshot["recipes"] = enhanced_recipes
	return snapshot


func _format_recipe_inputs(recipe: Dictionary) -> String:
	var inputs: Dictionary = recipe.get("inputs", {}) as Dictionary
	var parts: Array[String] = []
	for item_id_value: Variant in inputs.keys():
		var item_id: StringName = StringName(item_id_value)
		parts.append("%d %s" % [int(inputs[item_id_value]), _format_item_name(item_id)])
	return ", ".join(parts)


func _format_item_name(item_id: StringName) -> String:
	return DataRegistry.get_item_display_name(item_id)


func _get_item_debug_color(item_id: StringName) -> Color:
	if item_id == &"coal":
		return Color(0.18, 0.17, 0.15)
	if item_id == &"iron_ingot":
		return Color(0.72, 0.74, 0.76)
	if item_id == &"iron_armor":
		return Color(0.46, 0.50, 0.56)
	if item_id == &"fence":
		return Color(0.42, 0.24, 0.12)
	return Color(0.92, 0.78, 0.28)


func _on_station_crafting_changed(station: Node) -> void:
	if active_station != null and station == active_station:
		_refresh_active_station_ui()


func _on_station_craft_completed(station: Node, recipe: Dictionary) -> void:
	var output_item_id: StringName = StringName(recipe.get("output_item_id", &""))
	if output_item_id == &"":
		return

	_emit_temporary_hint("%s output ready" % _format_item_name(output_item_id))
	if active_station != null and station == active_station:
		_refresh_active_station_ui()


func _emit_temporary_hint(text: String) -> void:
	action_hint_changed.emit(text)
	_last_hint_time = 1.0


func _draw() -> void:
	draw_circle(Vector2.ZERO, 11.0, Color(0.18, 0.58, 0.92))
	draw_circle(Vector2.ZERO, 11.0, Color(0.05, 0.10, 0.16), false, 2.0)
	draw_line(Vector2.ZERO, facing * 17.0, Color(1.0, 0.95, 0.55), 3.0)
	var angle: float = facing.angle()
	draw_arc(Vector2.ZERO, cutter_lock_range, angle - 0.35, angle + 0.35, 12, Color(1.0, 1.0, 1.0, 0.22), 2.0)
	draw_circle(Vector2.ZERO, pickup_radius, Color(0.55, 0.85, 1.0, 0.10), false, 1.0)
	if _cutter_active:
		if _cutter_target != null and is_instance_valid(_cutter_target):
			var local_target_position: Vector2 = to_local(_cutter_target.global_position)
			var target_radius: float = _get_target_lock_radius(_cutter_target)
			draw_line(Vector2.ZERO, local_target_position, Color(0.35, 0.92, 1.0, 0.82), 3.0)
			draw_circle(local_target_position, target_radius + 7.0, Color(0.35, 0.92, 1.0, 0.92), false, 3.0)
			draw_circle(local_target_position, target_radius + 12.0, Color(0.35, 0.92, 1.0, 0.22), false, 2.0)

	if pending_building_id != &"":
		_draw_pending_building_preview()


func _get_pending_build_grid_position() -> Vector2i:
	if world == null:
		return Vector2i.ZERO
	return world.world_to_grid(get_global_mouse_position())


func _get_pending_building_footprint() -> Vector2i:
	if world == null:
		return Vector2i.ONE
	var definition: Dictionary = world.get_building_definition(pending_building_id)
	if definition.is_empty():
		return Vector2i.ONE
	return definition.get("footprint", Vector2i.ONE) as Vector2i


func _build_pending_building_transaction(grid_position: Vector2i) -> Dictionary:
	return _validate_building_placement(pending_building_id, grid_position, true)


func _validate_building_placement(building_id: StringName, grid_position: Vector2i, check_cost: bool) -> Dictionary:
	var result: Dictionary = {
		"valid": false,
		"reason": &"unknown",
		"building_id": building_id,
		"grid_position": grid_position,
		"cost": {},
		"display_name": String(building_id),
	}

	if building_id == &"":
		result["reason"] = &"no_pending_building"
		return result
	if world == null:
		result["reason"] = &"world_missing"
		return result
	var definition: Dictionary = world.get_building_definition(building_id)
	if definition.is_empty():
		result["reason"] = &"unknown_building"
		return result
	result["display_name"] = String(definition.get("display_name", String(building_id)))

	if not DataRegistry.has_building_cost(building_id):
		result["reason"] = &"missing_cost"
		return result
	var cost: Dictionary = DataRegistry.get_building_cost(building_id)
	result["cost"] = cost

	var footprint: Vector2i = definition.get("footprint", Vector2i.ONE) as Vector2i
	if not _is_building_in_range(grid_position, footprint):
		result["reason"] = &"out_of_range"
		return result

	if not world.can_place_building(building_id, grid_position):
		result["reason"] = &"blocked"
		return result

	if check_cost and not inventory.can_remove_items(cost):
		result["reason"] = &"missing_items"
		return result

	result["valid"] = true
	result["reason"] = &"ok"
	return result


func _is_building_in_range(grid_position: Vector2i, footprint: Vector2i) -> bool:
	if world == null:
		return false

	var center: Vector2 = world.grid_to_world_center(grid_position, footprint)
	return global_position.distance_to(center) <= build_range


func _emit_building_transaction_failure(transaction: Dictionary) -> void:
	var reason: StringName = StringName(transaction.get("reason", &"unknown"))
	if reason == &"out_of_range":
		_emit_temporary_hint("Build closer to the player")
	elif reason == &"missing_items":
		var cost: Dictionary = transaction.get("cost", {}) as Dictionary
		_emit_temporary_hint("Need %s" % _format_cost(cost))
	elif reason == &"missing_cost":
		_emit_temporary_hint("Missing building cost definition")
	elif reason == &"unknown_building":
		_emit_temporary_hint("Unknown building")
	elif reason == &"world_missing":
		_emit_temporary_hint("World is not ready")
	elif reason == &"building_system_missing":
		_emit_temporary_hint("Building system is not ready")
	else:
		_emit_temporary_hint("Cannot build there")


func _has_building_cost(building_id: StringName) -> bool:
	if not DataRegistry.has_building_cost(building_id):
		return false

	var cost: Dictionary = DataRegistry.get_building_cost(building_id)
	return inventory.can_remove_items(cost)


func _refund_cost(cost: Dictionary) -> void:
	for item_id_value: Variant in cost.keys():
		var item_id: StringName = StringName(item_id_value)
		var amount: int = int(cost[item_id_value])
		var leftover: int = inventory.add_item_with_leftover(item_id, amount)
		if leftover > 0 and world != null:
			world.spawn_ground_item(item_id, leftover, global_position, _get_item_debug_color(item_id))


func _format_building_cost(building_id: StringName) -> String:
	if not DataRegistry.has_building_cost(building_id):
		return "missing cost definition"

	var cost: Dictionary = DataRegistry.get_building_cost(building_id)
	return _format_cost(cost)


func _format_cost(cost: Dictionary) -> String:
	return DataRegistry.format_cost(cost)


func _draw_pending_building_preview() -> void:
	if world == null:
		return

	var grid_position: Vector2i = _get_pending_build_grid_position()
	var footprint: Vector2i = _get_pending_building_footprint()
	var tile_size: int = world.get_tile_size()
	var top_left: Vector2 = Vector2(float(grid_position.x * tile_size), float(grid_position.y * tile_size))
	var size: Vector2 = Vector2(float(footprint.x * tile_size), float(footprint.y * tile_size))
	var local_rect_position: Vector2 = top_left - global_position
	var transaction: Dictionary = _build_pending_building_transaction(grid_position)
	var can_place: bool = bool(transaction.get("valid", false))
	var reason: StringName = StringName(transaction.get("reason", &"unknown"))
	var color: Color = Color(0.35, 0.95, 0.48, 0.35) if can_place else Color(0.95, 0.25, 0.20, 0.35)
	draw_rect(Rect2(local_rect_position, size), color, true)
	draw_rect(Rect2(local_rect_position, size), color.darkened(0.35), false, 2.0)
	for x: int in range(1, footprint.x):
		var line_x: float = local_rect_position.x + float(x * tile_size)
		draw_line(Vector2(line_x, local_rect_position.y), Vector2(line_x, local_rect_position.y + size.y), color.darkened(0.45), 1.0)
	for y: int in range(1, footprint.y):
		var line_y: float = local_rect_position.y + float(y * tile_size)
		draw_line(Vector2(local_rect_position.x, line_y), Vector2(local_rect_position.x + size.x, line_y), color.darkened(0.45), 1.0)
	if not can_place:
		draw_line(local_rect_position, local_rect_position + size, Color(0.95, 0.12, 0.10, 0.95), 3.0)
		draw_line(local_rect_position + Vector2(size.x, 0.0), local_rect_position + Vector2(0.0, size.y), Color(0.95, 0.12, 0.10, 0.95), 3.0)
		if reason == &"out_of_range":
			draw_arc(Vector2.ZERO, build_range, 0.0, TAU, 48, Color(1.0, 0.86, 0.22, 0.45), 2.0)
