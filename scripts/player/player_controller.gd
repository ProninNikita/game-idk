extends CharacterBody2D
class_name PlayerController

signal inventory_changed(items: Dictionary)
signal inventory_slots_changed(slots: Array)
signal action_hint_changed(text: String)

@export var move_speed: float = 220.0
@export var attack_range: float = 46.0
@export var pickaxe_damage: int = 1
@export var attack_cooldown: float = 0.28
@export var pickup_radius: float = 34.0
@export var pickup_interval: float = 0.12

@onready var inventory: InventoryComponent = $Inventory
@onready var camera: Camera2D = $Camera2D

var world_bounds: Rect2 = Rect2()
var facing: Vector2 = Vector2.DOWN
var world: Node = null
var _cooldown_left: float = 0.0
var _last_hint_time: float = 0.0
var _pickup_left: float = 0.0


func _ready() -> void:
	add_to_group("player")
	inventory.changed.connect(_on_inventory_changed)
	queue_redraw()


func _physics_process(delta: float) -> void:
	_cooldown_left = max(0.0, _cooldown_left - delta)
	_last_hint_time = max(0.0, _last_hint_time - delta)
	_pickup_left = max(0.0, _pickup_left - delta)

	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed

	_update_mouse_facing()

	move_and_slide()
	_clamp_to_world()

	if _pickup_left <= 0.0:
		_pickup_left = pickup_interval
		_try_pickup_ground_items()

	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("interact"):
		_try_harvest()


func set_world(new_world: Node) -> void:
	world = new_world


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


func _try_harvest() -> void:
	if _cooldown_left > 0.0:
		return

	_cooldown_left = attack_cooldown
	var target: HarvestableResourceNode = _find_resource_target()
	if target == null:
		_emit_temporary_hint("No resource in pickaxe range")
		return

	var drop: Dictionary = target.hit(pickaxe_damage, [&"mining", &"cutting", &"harvesting"])
	if drop.has("item_id"):
		var item_id: StringName = StringName(drop["item_id"])
		var amount: int = int(drop.get("amount", 1))
		var drop_position: Vector2 = drop.get("position", target.global_position) as Vector2
		var drop_color: Color = drop.get("color", Color(0.92, 0.78, 0.28)) as Color
		if world != null and world.has_method("spawn_ground_item"):
			world.call("spawn_ground_item", item_id, amount, drop_position, drop_color)
		_emit_temporary_hint("Dropped %s x%d" % [String(item_id), amount])
	else:
		_emit_temporary_hint("%s damaged" % target.display_name)


func _find_resource_target() -> HarvestableResourceNode:
	var best_target: HarvestableResourceNode = null
	var best_score: float = INF

	for node: Node in get_tree().get_nodes_in_group("resource_nodes"):
		if not is_instance_valid(node):
			continue
		if not node is HarvestableResourceNode:
			continue

		var resource: HarvestableResourceNode = node as HarvestableResourceNode
		var to_target: Vector2 = resource.global_position - global_position
		var distance: float = to_target.length()
		if distance > attack_range:
			continue

		var direction_score: float = 1.0
		if distance > 0.01:
			direction_score = facing.dot(to_target.normalized())
			if direction_score < -0.15:
				continue

		var score: float = distance - direction_score * 18.0
		if score < best_score:
			best_score = score
			best_target = resource

	return best_target


func _clamp_to_world() -> void:
	if world_bounds.size == Vector2.ZERO:
		return

	var margin: float = 12.0
	global_position.x = clampf(global_position.x, world_bounds.position.x + margin, world_bounds.end.x - margin)
	global_position.y = clampf(global_position.y, world_bounds.position.y + margin, world_bounds.end.y - margin)


func _update_mouse_facing() -> void:
	var to_mouse: Vector2 = get_global_mouse_position() - global_position
	if to_mouse.length_squared() <= 4.0:
		return

	facing = to_mouse.normalized()
	queue_redraw()


func _try_pickup_ground_items() -> void:
	var candidates: Array[Node] = []
	for node: Node in get_tree().get_nodes_in_group("ground_items"):
		if not is_instance_valid(node):
			continue
		if not node.has_method("take"):
			continue

		if global_position.distance_to(node.global_position) <= pickup_radius:
			candidates.append(node)

	candidates.sort_custom(_sort_ground_items_by_distance)

	var picked_any: bool = false
	var inventory_full: bool = false

	for item: Node in candidates:
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
			if world != null and world.has_method("spawn_ground_item"):
				var item_color: Color = item.get("debug_color") as Color
				world.call("spawn_ground_item", item_id, leftover, item.global_position, item_color)
			inventory_full = true

		picked_any = true

	if picked_any:
		_emit_temporary_hint("Picked up items")
	elif inventory_full:
		_emit_temporary_hint("Inventory full")


func _sort_ground_items_by_distance(a: Node, b: Node) -> bool:
	return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)


func _on_inventory_changed(items: Dictionary) -> void:
	inventory_changed.emit(items)
	inventory_slots_changed.emit(inventory.get_slots())


func _emit_temporary_hint(text: String) -> void:
	action_hint_changed.emit(text)
	_last_hint_time = 1.0


func _draw() -> void:
	draw_circle(Vector2.ZERO, 11.0, Color(0.18, 0.58, 0.92))
	draw_circle(Vector2.ZERO, 11.0, Color(0.05, 0.10, 0.16), false, 2.0)
	draw_line(Vector2.ZERO, facing * 17.0, Color(1.0, 0.95, 0.55), 3.0)
	var angle: float = facing.angle()
	draw_arc(Vector2.ZERO, attack_range, angle - 0.35, angle + 0.35, 12, Color(1.0, 1.0, 1.0, 0.22), 2.0)
	draw_circle(Vector2.ZERO, pickup_radius, Color(0.55, 0.85, 1.0, 0.10), false, 1.0)
