extends Node2D
class_name HearthlineWorld

const RESOURCE_NODE_SCENE: PackedScene = preload("res://scenes/world/resource_node.tscn")

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

@export var map_size: Vector2i = Vector2i(150, 150)
@export var tile_size: int = 32
@export var world_seed: int = 18052026

@onready var resource_container: Node2D = $ResourceNodes

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _occupied: Dictionary = {}
var _resource_count: int = 0


func _ready() -> void:
	generate_world()
	queue_redraw()


func generate_world() -> void:
	_rng.seed = world_seed
	_occupied.clear()
	_resource_count = 0

	for child: Node in resource_container.get_children():
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
