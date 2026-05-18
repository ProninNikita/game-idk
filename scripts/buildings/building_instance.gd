extends StaticBody2D
class_name BuildingInstance

var building_id: StringName = &"building"
var display_name: String = "Building"
var footprint: Vector2i = Vector2i.ONE
var grid_position: Vector2i = Vector2i.ZERO
var tile_size: int = 32
var debug_color: Color = Color(0.55, 0.52, 0.48)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("buildings")
	_apply_collision_shape()
	queue_redraw()


func setup(new_id: StringName, new_display_name: String, new_grid_position: Vector2i, new_footprint: Vector2i, new_tile_size: int, color: Color) -> void:
	building_id = new_id
	display_name = new_display_name
	grid_position = new_grid_position
	footprint = new_footprint
	tile_size = new_tile_size
	debug_color = color
	position = Vector2(
		float(grid_position.x * tile_size) + float(footprint.x * tile_size) * 0.5,
		float(grid_position.y * tile_size) + float(footprint.y * tile_size) * 0.5
	)

	if is_inside_tree():
		_apply_collision_shape()
		queue_redraw()


func _apply_collision_shape() -> void:
	if collision_shape == null:
		return

	var shape: Shape2D = collision_shape.shape
	if shape is RectangleShape2D:
		if not shape.resource_local_to_scene:
			shape = shape.duplicate()
			shape.resource_local_to_scene = true
			collision_shape.shape = shape
		var rect_shape: RectangleShape2D = shape as RectangleShape2D
		rect_shape.size = Vector2(float(footprint.x * tile_size), float(footprint.y * tile_size))


func _draw() -> void:
	var size: Vector2 = Vector2(float(footprint.x * tile_size), float(footprint.y * tile_size))
	var rect: Rect2 = Rect2(-size * 0.5, size)
	draw_rect(rect, debug_color, true)
	draw_rect(rect, Color(0.06, 0.05, 0.04), false, 2.0)
	draw_rect(Rect2(rect.position + Vector2(8.0, 8.0), rect.size - Vector2(16.0, 16.0)), debug_color.darkened(0.18), false, 2.0)

	if building_id == &"furnace":
		draw_circle(Vector2.ZERO, 12.0, Color(0.95, 0.42, 0.16))
		draw_circle(Vector2.ZERO, 7.0, Color(1.0, 0.78, 0.25))
		draw_line(Vector2(-18.0, -18.0), Vector2(18.0, -18.0), Color(0.10, 0.09, 0.08), 3.0)
