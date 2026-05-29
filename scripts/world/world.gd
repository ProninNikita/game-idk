extends Node2D
class_name HearthlineWorld

signal time_of_day_changed(snapshot: Dictionary)

const RESOURCE_NODE_SCENE: PackedScene = preload("res://scenes/world/resource_node.tscn")
const GROUND_ITEM_SCENE: PackedScene = preload("res://scenes/world/ground_item.tscn")
const MONSTER_TARGET_SCENE: PackedScene = preload("res://scenes/world/monster_target.tscn")
const DataRegistry = preload("res://scripts/data/data_registry.gd")

const HOURS_PER_DAY: float = 24.0
const MINUTES_PER_HOUR: int = 60
const TIME_EMIT_INTERVAL_MINUTES: int = 1
const MORNING_START_HOUR: float = 6.0
const DAY_START_HOUR: float = 9.0
const EVENING_START_HOUR: float = 16.0
const NIGHT_START_HOUR: float = 22.0

const PHASE_NAMES: Dictionary = {
	&"morning": "Morning",
	&"day": "Day",
	&"evening": "Evening",
	&"night": "Night",
}

const TIME_TINT_KEYS: Array[Dictionary] = [
	{"hour": 0.0, "color": Color(0.34, 0.40, 0.58)},
	{"hour": MORNING_START_HOUR, "color": Color(0.92, 0.75, 0.58)},
	{"hour": DAY_START_HOUR, "color": Color(1.0, 1.0, 0.96)},
	{"hour": EVENING_START_HOUR, "color": Color(1.0, 0.78, 0.52)},
	{"hour": NIGHT_START_HOUR, "color": Color(0.34, 0.40, 0.58)},
	{"hour": HOURS_PER_DAY, "color": Color(0.34, 0.40, 0.58)},
]

@export var map_size: Vector2i = Vector2i(150, 150)
@export var tile_size: int = 32
@export var world_seed: int = 18052026
@export var day_length_seconds: float = 720.0
@export_range(0.0, 23.99, 0.01) var start_hour: float = MORNING_START_HOUR
@export var time_cycle_enabled: bool = true
@export var resource_respawn_enabled: bool = true
@export var resource_respawn_seconds: float = 120.0

@onready var resource_container: Node2D = $ResourceNodes
@onready var ground_item_container: Node2D = $GroundItems
@onready var building_container: Node2D = $Buildings
@onready var monster_container: Node2D = $Monsters

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _occupied: Dictionary = {}
var _building_occupied: Dictionary = {}
var _building_cells_by_instance: Dictionary = {}
var _resource_type_by_cell: Dictionary = {}
var _resource_nodes: Array[HarvestableResourceNode] = []
var _ground_items: Array[GroundItem] = []
var _buildings: Array[BuildingInstance] = []
var _station_buildings: Array[BuildingInstance] = []
var _damageable_nodes: Array[Node2D] = []
var _dynamic_placement_blockers: Array[Node2D] = []
var _resource_respawn_queue: Array[Dictionary] = []
var _resource_count: int = 0
var _time_of_day_hours: float = MORNING_START_HOUR
var _day_count: int = 1
var _last_emitted_minute: int = -1
var _last_emitted_phase: StringName = &""
var _daylight_modulate: CanvasModulate = null


func _ready() -> void:
	_time_of_day_hours = wrapf(start_hour, 0.0, HOURS_PER_DAY)
	_ensure_daylight_modulate()
	_apply_time_of_day_visuals()
	generate_world()
	_emit_time_of_day_changed(true)
	queue_redraw()


func _process(delta: float) -> void:
	if not time_cycle_enabled:
		_tick_machine_scheduler(delta)
		_tick_resource_respawns(delta)
		return
	if day_length_seconds > 0.0:
		_advance_time_of_day(delta)

	_tick_machine_scheduler(delta)
	_tick_resource_respawns(delta)


func generate_world() -> void:
	_rng.seed = world_seed
	_occupied.clear()
	_building_occupied.clear()
	_building_cells_by_instance.clear()
	_resource_type_by_cell.clear()
	_resource_nodes.clear()
	_ground_items.clear()
	_buildings.clear()
	_station_buildings.clear()
	_resource_respawn_queue.clear()
	_resource_count = 0

	for child: Node in resource_container.get_children():
		child.queue_free()
	for child: Node in ground_item_container.get_children():
		child.queue_free()
	for child: Node in building_container.get_children():
		child.queue_free()
	for child: Node in monster_container.get_children():
		child.queue_free()

	_spawn_resource_clusters(&"tree", 10, 42, 11)
	_spawn_resource_clusters(&"stone", 8, 28, 8)
	_spawn_resource_clusters(&"ore", 6, 20, 7)
	_spawn_resource_clusters(&"crop", 8, 34, 9)
	_spawn_scatter(&"tree", 120)
	_spawn_scatter(&"stone", 70)
	_spawn_scatter(&"crop", 90)
	_spawn_training_monster()


func get_spawn_position() -> Vector2:
	return Vector2(map_size.x * tile_size * 0.5, map_size.y * tile_size * 0.5)


func get_world_bounds() -> Rect2:
	return Rect2(Vector2.ZERO, Vector2(map_size.x * tile_size, map_size.y * tile_size))


func get_resource_count() -> int:
	return _resource_count


func get_resource_definition(resource_id: StringName) -> Dictionary:
	return DataRegistry.get_resource_definition(resource_id)


func get_time_of_day_snapshot() -> Dictionary:
	var hour: int = floori(_time_of_day_hours)
	var minute: int = floori((_time_of_day_hours - float(hour)) * float(MINUTES_PER_HOUR))
	var phase_id: StringName = get_time_phase_id(_time_of_day_hours)
	return {
		"day": _day_count,
		"hour": hour,
		"minute": minute,
		"phase_id": phase_id,
		"phase_name": String(PHASE_NAMES.get(phase_id, "Unknown")),
		"display_time": "%02d:%02d" % [hour, minute],
	}


func set_time_of_day(hour: float, day: int = -1) -> void:
	_time_of_day_hours = wrapf(hour, 0.0, HOURS_PER_DAY)
	if day > 0:
		_day_count = day
	_apply_time_of_day_visuals()
	_emit_time_of_day_changed(true)


func get_time_phase_id(hour: float) -> StringName:
	var wrapped_hour: float = wrapf(hour, 0.0, HOURS_PER_DAY)
	if wrapped_hour >= MORNING_START_HOUR and wrapped_hour < DAY_START_HOUR:
		return &"morning"
	if wrapped_hour >= DAY_START_HOUR and wrapped_hour < EVENING_START_HOUR:
		return &"day"
	if wrapped_hour >= EVENING_START_HOUR and wrapped_hour < NIGHT_START_HOUR:
		return &"evening"
	return &"night"


func spawn_ground_item(item_id: StringName, amount: int, spawn_position: Vector2, source_color: Color = Color(0.92, 0.78, 0.28)) -> GroundItem:
	var item: GroundItem = GROUND_ITEM_SCENE.instantiate() as GroundItem
	if item == null:
		return null
	var scatter: Vector2 = Vector2(_rng.randf_range(-10.0, 10.0), _rng.randf_range(-10.0, 10.0))
	item.setup(item_id, amount, spawn_position + scatter, source_color)
	ground_item_container.add_child(item)
	_register_ground_item(item)
	return item


func get_tile_size() -> int:
	return tile_size


func world_to_grid(world_position: Vector2) -> Vector2i:
	return Vector2i(floori(world_position.x / float(tile_size)), floori(world_position.y / float(tile_size)))


func grid_to_world_center(grid_position: Vector2i, footprint: Vector2i = Vector2i.ONE) -> Vector2:
	return Vector2(
		float(grid_position.x * tile_size) + float(footprint.x * tile_size) * 0.5,
		float(grid_position.y * tile_size) + float(footprint.y * tile_size) * 0.5
	)


func get_building_definition(building_id: StringName) -> Dictionary:
	return DataRegistry.get_building_definition(building_id)


func can_place_building(building_id: StringName, grid_position: Vector2i) -> bool:
	var definition: Dictionary = get_building_definition(building_id)
	if definition.is_empty():
		return false

	var footprint: Vector2i = definition.get("footprint", Vector2i.ONE) as Vector2i
	return _can_fit_footprint(grid_position, footprint)


func place_building(building_id: StringName, grid_position: Vector2i) -> bool:
	if not can_place_building(building_id, grid_position):
		return false

	var definition: Dictionary = get_building_definition(building_id)
	var scene: PackedScene = definition.get("scene") as PackedScene
	if scene == null:
		return false
	var footprint: Vector2i = definition.get("footprint", Vector2i.ONE) as Vector2i
	var display_name: String = String(definition.get("display_name", String(building_id)))
	var color: Color = definition.get("color", Color(0.48, 0.42, 0.36)) as Color
	var building: BuildingInstance = scene.instantiate() as BuildingInstance
	if building == null:
		return false
	building.setup(building_id, display_name, grid_position, footprint, tile_size, color)
	building_container.add_child(building)
	_register_building_instance(building)
	_register_building_occupancy(building, grid_position, footprint)
	return true


func tick_machines(delta: float) -> void:
	_tick_machine_scheduler(delta)


func register_dynamic_placement_blocker(blocker: Node2D) -> void:
	if blocker == null:
		return
	if _dynamic_placement_blockers.has(blocker):
		return
	_dynamic_placement_blockers.append(blocker)
	var exiting_callable: Callable = Callable(self, "_on_dynamic_blocker_tree_exiting").bind(blocker.get_instance_id())
	if not blocker.tree_exiting.is_connected(exiting_callable):
		blocker.tree_exiting.connect(exiting_callable, CONNECT_ONE_SHOT)


func unregister_dynamic_placement_blocker(blocker: Node2D) -> void:
	if blocker == null:
		return
	_dynamic_placement_blockers.erase(blocker)


func register_damageable_node(node: Node2D) -> void:
	if node == null:
		return
	if _damageable_nodes.has(node):
		return
	_damageable_nodes.append(node)
	var exiting_callable: Callable = Callable(self, "_on_damageable_tree_exiting").bind(node.get_instance_id())
	if not node.tree_exiting.is_connected(exiting_callable):
		node.tree_exiting.connect(exiting_callable, CONNECT_ONE_SHOT)


func get_cutter_targets() -> Array[Node2D]:
	var targets: Array[Node2D] = []
	for resource: HarvestableResourceNode in _resource_nodes:
		if _is_valid_query_node(resource):
			targets.append(resource)
	for damageable: Node2D in _damageable_nodes:
		if _is_valid_query_node(damageable):
			targets.append(damageable)
	for building: BuildingInstance in _buildings:
		if _is_valid_query_node(building):
			targets.append(building)
	return targets


func get_ground_items_near(world_position: Vector2, radius: float) -> Array[GroundItem]:
	var result: Array[GroundItem] = []
	var radius_squared: float = radius * radius
	for item: GroundItem in _ground_items:
		if not _is_valid_query_node(item):
			continue
		if item.global_position.distance_squared_to(world_position) <= radius_squared:
			result.append(item)
	return result


func find_station_at_point(target_position: Vector2, actor_position: Vector2, interact_range: float) -> BuildingInstance:
	var best_station: BuildingInstance = null
	var best_score: float = INF
	for station: BuildingInstance in _station_buildings:
		if not _is_valid_query_node(station):
			continue
		if not station.has_station_recipes():
			continue
		if actor_position.distance_to(station.global_position) > interact_range:
			continue
		if not _is_point_inside_building(station, target_position):
			continue

		var score: float = target_position.distance_squared_to(station.global_position)
		if score < best_score:
			best_score = score
			best_station = station
	return best_station


func _advance_time_of_day(delta: float) -> void:
	var previous_hour: float = _time_of_day_hours
	_time_of_day_hours += delta * HOURS_PER_DAY / day_length_seconds
	if _time_of_day_hours >= HOURS_PER_DAY:
		_time_of_day_hours = fmod(_time_of_day_hours, HOURS_PER_DAY)
		if previous_hour > _time_of_day_hours:
			_day_count += 1

	_apply_time_of_day_visuals()
	_emit_time_of_day_changed(false)


func _ensure_daylight_modulate() -> void:
	if _daylight_modulate != null:
		return

	_daylight_modulate = CanvasModulate.new()
	_daylight_modulate.name = "DaylightModulate"
	add_child(_daylight_modulate)


func _apply_time_of_day_visuals() -> void:
	_ensure_daylight_modulate()
	if _daylight_modulate == null:
		return

	_daylight_modulate.color = _get_time_tint(_time_of_day_hours)


func _emit_time_of_day_changed(force: bool) -> void:
	var current_minute: int = floori(_time_of_day_hours * float(MINUTES_PER_HOUR))
	var current_phase: StringName = get_time_phase_id(_time_of_day_hours)
	var minute_changed: bool = absi(current_minute - _last_emitted_minute) >= TIME_EMIT_INTERVAL_MINUTES
	if not force and not minute_changed and current_phase == _last_emitted_phase:
		return

	_last_emitted_minute = current_minute
	_last_emitted_phase = current_phase
	time_of_day_changed.emit(get_time_of_day_snapshot())


func _get_time_tint(hour: float) -> Color:
	var wrapped_hour: float = wrapf(hour, 0.0, HOURS_PER_DAY)
	for i: int in range(TIME_TINT_KEYS.size() - 1):
		var from_key: Dictionary = TIME_TINT_KEYS[i]
		var to_key: Dictionary = TIME_TINT_KEYS[i + 1]
		var from_hour: float = float(from_key["hour"])
		var to_hour: float = float(to_key["hour"])
		if wrapped_hour < from_hour or wrapped_hour > to_hour:
			continue

		var segment_length: float = maxf(to_hour - from_hour, 0.01)
		var segment_progress: float = clampf((wrapped_hour - from_hour) / segment_length, 0.0, 1.0)
		return (from_key["color"] as Color).lerp(to_key["color"] as Color, segment_progress)

	return TIME_TINT_KEYS[0]["color"] as Color


func _spawn_resource_clusters(resource_type: StringName, cluster_count: int, amount_per_cluster: int, radius: int) -> void:
	for i in range(cluster_count):
		var center: Vector2i = _random_grid_position()
		_spawn_cluster(resource_type, center, amount_per_cluster, radius)


func _spawn_cluster(resource_type: StringName, center: Vector2i, amount: int, radius: int) -> void:
	var spawned: int = 0
	var attempts: int = amount * 12

	while spawned < amount and attempts > 0:
		attempts -= 1
		var offset: Vector2i = Vector2i(_rng.randi_range(-radius, radius), _rng.randi_range(-radius, radius))
		if Vector2(float(offset.x), float(offset.y)).length() > float(radius):
			continue

		var grid_pos: Vector2i = Vector2i(
			clampi(center.x + offset.x, 2, map_size.x - 3),
			clampi(center.y + offset.y, 2, map_size.y - 3)
		)

		if _try_spawn_resource(resource_type, grid_pos):
			spawned += 1


func _spawn_scatter(resource_type: StringName, amount: int) -> void:
	var spawned: int = 0
	var attempts: int = amount * 20

	while spawned < amount and attempts > 0:
		attempts -= 1
		if _try_spawn_resource(resource_type, _random_grid_position()):
			spawned += 1


func _spawn_training_monster() -> void:
	var monster: Node2D = MONSTER_TARGET_SCENE.instantiate() as Node2D
	if monster == null:
		return
	var spawn_position: Vector2 = get_spawn_position() + Vector2(180.0, -96.0)
	if monster.has_method("setup"):
		monster.call("setup", spawn_position)
	else:
		monster.global_position = spawn_position
	monster_container.add_child(monster)
	register_damageable_node(monster)


func _try_spawn_resource(resource_type: StringName, grid_pos: Vector2i) -> bool:
	if _is_in_spawn_clearance(grid_pos):
		return false
	if not DataRegistry.has_resource(resource_type):
		return false

	var key: String = _grid_key(grid_pos)
	if _occupied.has(key) or _building_occupied.has(key):
		return false

	var definition: Dictionary = DataRegistry.get_resource_definition(resource_type)
	if definition.is_empty():
		return false

	var node: HarvestableResourceNode = RESOURCE_NODE_SCENE.instantiate() as HarvestableResourceNode
	node.setup(resource_type, grid_pos, tile_size, definition)
	node.depleted.connect(_on_resource_depleted)
	resource_container.add_child(node)
	_register_resource_node(node)
	_occupied[key] = true
	_resource_type_by_cell[key] = resource_type
	_resource_count += 1
	return true


func _on_resource_depleted(grid_pos: Vector2i, resource_type: StringName = &"") -> void:
	var key: String = _grid_key(grid_pos)
	if not _occupied.has(key):
		return

	var depleted_type: StringName = resource_type
	if depleted_type == &"":
		depleted_type = StringName(_resource_type_by_cell.get(key, &""))
	_occupied.erase(key)
	_resource_type_by_cell.erase(key)
	_resource_count = maxi(_resource_count - 1, 0)
	if resource_respawn_enabled and depleted_type != &"":
		_resource_respawn_queue.append({
			"resource_type": depleted_type,
			"grid_position": grid_pos,
			"time_left": resource_respawn_seconds,
		})


func _can_fit_footprint(grid_position: Vector2i, footprint: Vector2i) -> bool:
	var footprint_keys: Dictionary = {}
	for x: int in range(grid_position.x, grid_position.x + footprint.x):
		for y: int in range(grid_position.y, grid_position.y + footprint.y):
			if x < 0 or y < 0 or x >= map_size.x or y >= map_size.y:
				return false
			var key: String = _grid_key(Vector2i(x, y))
			if _occupied.has(key) or _building_occupied.has(key):
				return false
			footprint_keys[key] = true

	if _has_dynamic_placement_blocker(footprint_keys):
		return false
	return true


func _has_dynamic_placement_blocker(footprint_keys: Dictionary) -> bool:
	for blocker: Node2D in _dynamic_placement_blockers:
		if not _is_valid_query_node(blocker):
			continue
		if footprint_keys.has(_grid_key(world_to_grid(blocker.global_position))):
			return true

	return false


func _register_building_occupancy(building: Node, grid_position: Vector2i, footprint: Vector2i) -> void:
	var instance_id: int = building.get_instance_id()
	var cells: Array[String] = _get_footprint_keys(grid_position, footprint)
	_building_cells_by_instance[instance_id] = cells
	for key: String in cells:
		_building_occupied[key] = instance_id

	building.tree_exiting.connect(_on_building_tree_exiting.bind(instance_id), CONNECT_ONE_SHOT)


func _on_building_tree_exiting(instance_id: int) -> void:
	_unregister_building_instance(instance_id)
	_release_building_occupancy(instance_id)


func _register_resource_node(node: HarvestableResourceNode) -> void:
	if node == null:
		return
	_resource_nodes.append(node)
	node.tree_exiting.connect(_on_resource_tree_exiting.bind(node.get_instance_id()), CONNECT_ONE_SHOT)


func _register_ground_item(item: GroundItem) -> void:
	if item == null:
		return
	_ground_items.append(item)
	item.tree_exiting.connect(_on_ground_item_tree_exiting.bind(item.get_instance_id()), CONNECT_ONE_SHOT)


func _register_building_instance(building: BuildingInstance) -> void:
	if building == null:
		return
	_buildings.append(building)
	if building.has_station_recipes():
		_station_buildings.append(building)
		var overflow_callable: Callable = Callable(self, "_on_station_output_overflow")
		if not building.output_overflow_requested.is_connected(overflow_callable):
			building.output_overflow_requested.connect(overflow_callable)
	var destroyed_callable: Callable = Callable(self, "_on_building_destroyed")
	if not building.destroyed.is_connected(destroyed_callable):
		building.destroyed.connect(destroyed_callable)


func _unregister_building_instance(instance_id: int) -> void:
	_erase_node_from_array_by_instance(_buildings, instance_id)
	_erase_node_from_array_by_instance(_station_buildings, instance_id)


func _on_resource_tree_exiting(instance_id: int) -> void:
	_erase_node_from_array_by_instance(_resource_nodes, instance_id)


func _on_ground_item_tree_exiting(instance_id: int) -> void:
	_erase_node_from_array_by_instance(_ground_items, instance_id)


func _on_dynamic_blocker_tree_exiting(instance_id: int) -> void:
	_erase_node_from_array_by_instance(_dynamic_placement_blockers, instance_id)


func _on_damageable_tree_exiting(instance_id: int) -> void:
	_erase_node_from_array_by_instance(_damageable_nodes, instance_id)


func _on_station_output_overflow(station: Node, item_id: StringName, amount: int, drop_position: Vector2, color: Color) -> void:
	spawn_ground_item(item_id, amount, drop_position, color)


func _on_building_destroyed(building: Node, refund_items: Dictionary) -> void:
	var drop_position: Vector2 = Vector2.ZERO
	if building is Node2D:
		drop_position = (building as Node2D).global_position
	for item_id_value: Variant in refund_items.keys():
		var item_id: StringName = StringName(item_id_value)
		var amount: int = int(refund_items[item_id_value])
		if amount > 0:
			spawn_ground_item(item_id, amount, drop_position, _get_item_debug_color(item_id))


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


func _tick_machine_scheduler(delta: float) -> void:
	for station: BuildingInstance in _station_buildings:
		if _is_valid_query_node(station):
			station.tick_station(delta)


func _tick_resource_respawns(delta: float) -> void:
	if not resource_respawn_enabled:
		return

	for i: int in range(_resource_respawn_queue.size() - 1, -1, -1):
		var entry: Dictionary = _resource_respawn_queue[i]
		entry["time_left"] = float(entry.get("time_left", 0.0)) - delta
		if float(entry["time_left"]) > 0.0:
			_resource_respawn_queue[i] = entry
			continue

		var resource_type: StringName = StringName(entry.get("resource_type", &""))
		var grid_position: Vector2i = entry.get("grid_position", Vector2i.ZERO) as Vector2i
		if _try_spawn_resource(resource_type, grid_position):
			_resource_respawn_queue.remove_at(i)
		else:
			entry["time_left"] = resource_respawn_seconds
			_resource_respawn_queue[i] = entry


func _is_valid_query_node(node: Node) -> bool:
	if node == null:
		return false
	if not is_instance_valid(node):
		return false
	if node.is_queued_for_deletion():
		return false
	if not node.is_inside_tree():
		return false
	return true


func _is_point_inside_building(building: BuildingInstance, point: Vector2) -> bool:
	var size: Vector2 = Vector2(float(building.footprint.x * building.tile_size), float(building.footprint.y * building.tile_size))
	var rect: Rect2 = Rect2(building.global_position - size * 0.5, size).grow(6.0)
	return rect.has_point(point)


func _erase_node_from_array_by_instance(nodes: Array, instance_id: int) -> void:
	for i: int in range(nodes.size() - 1, -1, -1):
		var node: Node = nodes[i] as Node
		if node == null:
			nodes.remove_at(i)
			continue
		if not is_instance_valid(node) or node.get_instance_id() == instance_id:
			nodes.remove_at(i)


func _release_building_occupancy(instance_id: int) -> void:
	var cells: Array = _building_cells_by_instance.get(instance_id, []) as Array
	for key_value: Variant in cells:
		var key: String = key_value as String
		if int(_building_occupied.get(key, 0)) == instance_id:
			_building_occupied.erase(key)
	_building_cells_by_instance.erase(instance_id)


func _get_footprint_keys(grid_position: Vector2i, footprint: Vector2i) -> Array[String]:
	var cells: Array[String] = []
	for x: int in range(grid_position.x, grid_position.x + footprint.x):
		for y: int in range(grid_position.y, grid_position.y + footprint.y):
			cells.append(_grid_key(Vector2i(x, y)))
	return cells


func _random_grid_position() -> Vector2i:
	return Vector2i(
		_rng.randi_range(2, map_size.x - 3),
		_rng.randi_range(2, map_size.y - 3)
	)


func _is_in_spawn_clearance(grid_pos: Vector2i) -> bool:
	var center: Vector2 = Vector2(float(map_size.x), float(map_size.y)) * 0.5
	var pos: Vector2 = Vector2(float(grid_pos.x), float(grid_pos.y))
	return pos.distance_to(center) < 8.0


func _grid_key(grid_pos: Vector2i) -> String:
	return "%d:%d" % [grid_pos.x, grid_pos.y]


func _draw() -> void:
	var world_size: Vector2 = Vector2(map_size.x * tile_size, map_size.y * tile_size)
	draw_rect(Rect2(Vector2.ZERO, world_size), Color(0.18, 0.28, 0.20), true)

	var major_step: int = tile_size * 10
	for x: int in range(0, int(world_size.x) + 1, major_step):
		draw_line(Vector2(x, 0), Vector2(x, world_size.y), Color(0.08, 0.12, 0.09, 0.45), 1.0)
	for y: int in range(0, int(world_size.y) + 1, major_step):
		draw_line(Vector2(0, y), Vector2(world_size.x, y), Color(0.08, 0.12, 0.09, 0.45), 1.0)

	draw_rect(Rect2(Vector2.ZERO, world_size), Color(0.85, 0.95, 0.75), false, 4.0)
