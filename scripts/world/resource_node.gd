extends StaticBody2D
class_name HarvestableResourceNode

signal depleted(grid_position: Vector2i, resource_type: StringName)

var resource_type: StringName = &"tree"
var display_name: String = "Resource"
var drop_item_id: StringName = &"wood"
var drop_amount: int = 1
var max_health: float = 3.0
var health: float = 3.0
var grid_position: Vector2i = Vector2i.ZERO
var tile_size: int = 32
var debug_color: Color = Color(0.35, 0.75, 0.28)
var collision_radius: float = 12.0

var _hit_flash: float = 0.0
var _depleted: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("resource_nodes")
	_apply_collision_shape()
	queue_redraw()


func setup(type: StringName, grid_pos: Vector2i, cell_size: int, definition: Dictionary) -> void:
	resource_type = type
	grid_position = grid_pos
	tile_size = cell_size
	display_name = String(definition.get("display_name", String(type)))
	drop_item_id = StringName(definition.get("drop_item_id", type))
	drop_amount = int(definition.get("drop_amount", 1))
	max_health = float(definition.get("max_health", 3))
	health = max_health
	debug_color = definition.get("color", debug_color) as Color
	collision_radius = float(definition.get("collision_radius", definition.get("radius", 12.0)))
	position = Vector2((grid_position.x + 0.5) * tile_size, (grid_position.y + 0.5) * tile_size)

	if is_inside_tree():
		_apply_collision_shape()
		queue_redraw()


func hit(damage: float, tool_tags: Array) -> Dictionary:
	if _depleted:
		return {}
	if damage <= 0:
		return {}
	if tool_tags.is_empty():
		return {}

	health -= damage
	_hit_flash = maxf(_hit_flash, 0.55)
	queue_redraw()

	if health <= 0:
		_depleted = true
		depleted.emit(grid_position, resource_type)
		remove_from_group("resource_nodes")
		set_deferred("collision_layer", 0)
		set_deferred("collision_mask", 0)
		hide()
		queue_free()
		return {
			"item_id": drop_item_id,
			"amount": drop_amount,
			"color": debug_color,
			"position": global_position,
		}

	return {}


func _process(delta: float) -> void:
	if _hit_flash <= 0.0:
		return

	_hit_flash = max(0.0, _hit_flash - delta * 7.5)
	queue_redraw()


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
		circle_shape.radius = collision_radius


func _draw() -> void:
	var color: Color = debug_color.lerp(Color.WHITE, _hit_flash * 0.65)
	var health_ratio: float = 0.0
	if max_health > 0.0:
		health_ratio = clampf(health / max_health, 0.0, 1.0)

	if resource_type == &"tree":
		draw_rect(Rect2(Vector2(-4, -4), Vector2(8, 17)), Color(0.34, 0.20, 0.10), true)
		draw_circle(Vector2(0, -7), 14.0, color)
		draw_circle(Vector2(0, -7), 14.0, Color(0.06, 0.10, 0.04), false, 2.0)
	elif resource_type == &"stone":
		var points: PackedVector2Array = PackedVector2Array([
			Vector2(-13, 8),
			Vector2(-9, -8),
			Vector2(5, -13),
			Vector2(14, -2),
			Vector2(9, 10),
		])
		var outline: PackedVector2Array = PackedVector2Array(points)
		outline.append(points[0])
		draw_colored_polygon(points, color)
		draw_polyline(outline, Color(0.08, 0.08, 0.09), 2.0)
	elif resource_type == &"ore":
		draw_circle(Vector2.ZERO, 13.0, color)
		draw_circle(Vector2(4, -3), 5.0, Color(0.86, 0.64, 0.25).lerp(Color.WHITE, _hit_flash))
		draw_circle(Vector2.ZERO, 13.0, Color(0.06, 0.06, 0.08), false, 2.0)
	elif resource_type == &"crop":
		draw_rect(Rect2(Vector2(-11, -8), Vector2(22, 16)), Color(0.18, 0.30, 0.12), true)
		draw_circle(Vector2(-5, -2), 5.0, color)
		draw_circle(Vector2(4, 3), 5.0, color.darkened(0.1))
		draw_rect(Rect2(Vector2(-11, -8), Vector2(22, 16)), Color(0.04, 0.08, 0.03), false, 2.0)
	else:
		draw_circle(Vector2.ZERO, 12.0, color)

	var bar_width: float = 22.0
	var bar_y: float = -24.0
	draw_rect(Rect2(Vector2(-bar_width * 0.5, bar_y), Vector2(bar_width, 3.0)), Color(0.05, 0.05, 0.05, 0.8), true)
	draw_rect(Rect2(Vector2(-bar_width * 0.5, bar_y), Vector2(bar_width * health_ratio, 3.0)), Color(0.8, 0.95, 0.45), true)
