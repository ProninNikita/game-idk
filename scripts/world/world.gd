extends Node2D
class_name HearthlineWorld

const RESOURCE_NODE_SCENE: PackedScene = preload("res://scenes/world/resource_node.tscn")
const GROUND_ITEM_SCENE: PackedScene = preload("res://scenes/world/ground_item.tscn")
const FURNACE_SCENE: PackedScene = preload("res://scenes/buildings/furnace.tscn")

const RESOURCE_DEFS: Dictionary = {
	&"tree": {
		"display_name": "Tree",
		"drop_item_id": &"wood",
		"drop_amount": 4,
		"max_health": 3,
		"radius": 13.0,
		"color": Color(0.23, 0.62, 0.25),
	},
	&"stone": {
		"display_name": "Stone",
		"drop_item_id": &"stone",
		"drop_amount": 3,
		"max_health": 4,
		"radius": 12.0,
		"color": Color(0.49, 0.52, 0.55),
	},
	&"ore": {
		"display_name": "Ore",
		"drop_item_id": &"ore",
		"drop_amount": 2,
		"max_health": 5,
		"radius": 13.0,
		"color": Color(0.34, 0.35, 0.43),
	},
	&"crop": {
		"display_name": "Wild Crop",
		"drop_item_id": &"crop",
		"drop_amount": 2,
		"max_health": 2,
		"radius": 10.0,
		"color": Color(0.68, 0.83, 0.25),
	},
}

const BUILDING_DEFS: Dictionary = {
	&"furnace": {
		"display_name": "Furnace",
		"footprint": Vector2i(2, 2),
		"scene": FURNACE_SCENE,
		"color": Color(0.48, 0.42, 0.36),
	},
}

@export var map_size: Vector2i = Vector2i(150, 150)
@export var tile_size: int = 32
@export var world_seed: int = 18052026

@onready var resource_container: Node2D = $ResourceNodes
@onready var ground_item_container: Node2D = $GroundItems
@onready var building_container: Node2D = $Buildings

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _occupied: Dictionary = {}
var _building_occupied: Dictionary = {}
var _resource_count: int = 0


func _ready() -> void:
	generate_world()
	queue_redraw()


func generate_world() -> void:
	_rng.seed = world_seed
	_occupied.clear()
	_building_occupied.clear()
	_resource_count = 0

	for child: Node in resource_container.get_children():
		child.queue_free()
	for child: Node in ground_item_container.get_children():
		child.queue_free()
	for child: Node in building_container.get_children():
		child.queue_free()

	_spawn_resource_clusters(&"tree", 10, 42, 11)
	_spawn_resource_clusters(&"stone", 8, 28, 8)
	_spawn_resource_clusters(&"ore", 6, 20, 7)
	_spawn_resource_clusters(&"crop", 8, 34, 9)
	_spawn_scatter(&"tree", 120)
	_spawn_scatter(&"stone", 70)
	_spawn_scatter(&"crop", 90)


func get_spawn_position() -> Vector2:
	return Vector2(map_size.x * tile_size * 0.5, map_size.y * tile_size * 0.5)


func get_world_bounds() -> Rect2:
	return Rect2(Vector2.ZERO, Vector2(map_size.x * tile_size, map_size.y * tile_size))


func get_resource_count() -> int:
	return _resource_count


func spawn_ground_item(item_id: StringName, amount: int, spawn_position: Vector2, source_color: Color = Color(0.92, 0.78, 0.28)) -> Node:
	var item: Node = GROUND_ITEM_SCENE.instantiate()
	var scatter: Vector2 = Vector2(_rng.randf_range(-10.0, 10.0), _rng.randf_range(-10.0, 10.0))
	item.call("setup", item_id, amount, spawn_position + scatter, source_color)
	ground_item_container.add_child(item)
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
	if not BUILDING_DEFS.has(building_id):
		return {}
	return BUILDING_DEFS[building_id] as Dictionary


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
	var footprint: Vector2i = definition.get("footprint", Vector2i.ONE) as Vector2i
	var display_name: String = String(definition.get("display_name", String(building_id)))
	var color: Color = definition.get("color", Color(0.48, 0.42, 0.36)) as Color
	var building: Node = scene.instantiate()
	building.call("setup", building_id, display_name, grid_position, footprint, tile_size, color)
	building_container.add_child(building)
	_mark_building_occupied(grid_position, footprint)
	return true


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


func _try_spawn_resource(resource_type: StringName, grid_pos: Vector2i) -> bool:
	if _is_in_spawn_clearance(grid_pos):
		return false
	if not RESOURCE_DEFS.has(resource_type):
		return false

	var key: String = _grid_key(grid_pos)
	if _occupied.has(key):
		return false

	var node: HarvestableResourceNode = RESOURCE_NODE_SCENE.instantiate() as HarvestableResourceNode
	node.setup(resource_type, grid_pos, tile_size, RESOURCE_DEFS[resource_type] as Dictionary)
	resource_container.add_child(node)
	_occupied[key] = true
	_resource_count += 1
	return true


func _can_fit_footprint(grid_position: Vector2i, footprint: Vector2i) -> bool:
	for x: int in range(grid_position.x, grid_position.x + footprint.x):
		for y: int in range(grid_position.y, grid_position.y + footprint.y):
			if x < 0 or y < 0 or x >= map_size.x or y >= map_size.y:
				return false
			var key: String = _grid_key(Vector2i(x, y))
			if _occupied.has(key) or _building_occupied.has(key):
				return false
	return true


func _mark_building_occupied(grid_position: Vector2i, footprint: Vector2i) -> void:
	for x: int in range(grid_position.x, grid_position.x + footprint.x):
		for y: int in range(grid_position.y, grid_position.y + footprint.y):
			_building_occupied[_grid_key(Vector2i(x, y))] = true


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
