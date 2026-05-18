extends Area2D
class_name GroundItem

@export var pickup_radius: float = 18.0

var item_id: StringName = &"wood"
var amount: int = 1
var debug_color: Color = Color(0.92, 0.78, 0.28)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("ground_items")
	_apply_collision_shape()
	queue_redraw()


func setup(new_item_id: StringName, new_amount: int, spawn_position: Vector2, color: Color) -> void:
	item_id = new_item_id
	amount = max(1, new_amount)
	global_position = spawn_position
	debug_color = color

	if is_inside_tree():
		_apply_collision_shape()
		queue_redraw()


func take(requested_amount: int) -> int:
	if requested_amount <= 0:
		return 0

	var taken: int = mini(requested_amount, amount)
	amount -= taken
	if amount <= 0:
		remove_from_group("ground_items")
		queue_free()
	else:
		queue_redraw()

	return taken


func get_pickup_label() -> String:
	return "%s x%d" % [String(item_id), amount]


func _apply_collision_shape() -> void:
	if collision_shape == null:
		return

	var shape: Shape2D = collision_shape.shape
	if shape is CircleShape2D:
		if not shape.resource_local_to_scene:
			shape = shape.duplicate()
			shape.resource_local_to_scene = true
			collision_shape.shape = shape
		var circle_shape: CircleShape2D = shape as CircleShape2D
		circle_shape.radius = pickup_radius


func _draw() -> void:
	draw_circle(Vector2.ZERO, 7.0, debug_color)
	draw_circle(Vector2.ZERO, 7.0, Color(0.05, 0.05, 0.05), false, 2.0)
	draw_circle(Vector2(2, -2), 2.0, Color.WHITE.lerp(debug_color, 0.35))
	if amount > 1:
		draw_rect(Rect2(Vector2(-8, 8), Vector2(16, 4)), Color(0.05, 0.05, 0.05, 0.7), true)
		draw_rect(Rect2(Vector2(-6, 9), Vector2(12, 2)), debug_color.lightened(0.35), true)
