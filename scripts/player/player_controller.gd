extends CharacterBody2D
class_name PlayerController

signal inventory_changed(items: Dictionary)
signal action_hint_changed(text: String)

@export var move_speed: float = 220.0
@export var attack_range: float = 46.0
@export var pickaxe_damage: int = 1
@export var attack_cooldown: float = 0.28

@onready var inventory: InventoryComponent = $Inventory
@onready var camera: Camera2D = $Camera2D

var world_bounds: Rect2 = Rect2()
var facing: Vector2 = Vector2.DOWN
var _cooldown_left: float = 0.0
var _last_hint_time: float = 0.0


func _ready() -> void:
	add_to_group("player")
	inventory.changed.connect(_on_inventory_changed)
	queue_redraw()


func _physics_process(delta: float) -> void:
	_cooldown_left = max(0.0, _cooldown_left - delta)
	_last_hint_time = max(0.0, _last_hint_time - delta)

	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed

	if input_vector.length_squared() > 0.01:
		facing = input_vector.normalized()
		queue_redraw()

	move_and_slide()
	_clamp_to_world()

	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("interact"):
		_try_harvest()


func set_world_bounds(bounds: Rect2) -> void:
	world_bounds = bounds
	if camera != null:
		camera.limit_left = int(bounds.position.x)
		camera.limit_top = int(bounds.position.y)
		camera.limit_right = int(bounds.end.x)
		camera.limit_bottom = int(bounds.end.y)


func get_inventory_snapshot() -> Dictionary:
	return inventory.get_items()


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
		inventory.add_item(item_id, amount)
		_emit_temporary_hint("+%d %s" % [amount, String(item_id)])
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


func _on_inventory_changed(items: Dictionary) -> void:
	inventory_changed.emit(items)


func _emit_temporary_hint(text: String) -> void:
	action_hint_changed.emit(text)
	_last_hint_time = 1.0


func _draw() -> void:
	draw_circle(Vector2.ZERO, 11.0, Color(0.18, 0.58, 0.92))
	draw_circle(Vector2.ZERO, 11.0, Color(0.05, 0.10, 0.16), false, 2.0)
	draw_line(Vector2.ZERO, facing * 17.0, Color(1.0, 0.95, 0.55), 3.0)
	var angle: float = facing.angle()
	draw_arc(Vector2.ZERO, attack_range, angle - 0.35, angle + 0.35, 12, Color(1.0, 1.0, 1.0, 0.22), 2.0)
