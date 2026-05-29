extends StaticBody2D
class_name DamageableMonsterTarget

signal defeated(monster: Node)

var display_name: String = "Training Drone"
var max_health: float = 8.0
var health: float = 8.0
var collision_radius: float = 14.0
var debug_color: Color = Color(0.74, 0.22, 0.30)

var _hit_flash: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("damageable")
	_apply_collision_shape()
	queue_redraw()


func setup(spawn_position: Vector2) -> void:
	global_position = spawn_position


func hit(damage: float, tool_tags: Array) -> Dictionary:
	if damage <= 0.0:
		return {}
	if tool_tags.is_empty():
		return {}

	health = maxf(0.0, health - damage)
	_hit_flash = 0.55
	queue_redraw()
	if health > 0.0:
		return {}

	defeated.emit(self)
	queue_free()
	return {}


func _process(delta: float) -> void:
	if _hit_flash <= 0.0:
		return
	_hit_flash = maxf(0.0, _hit_flash - delta * 6.0)
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
	var color: Color = debug_color.lerp(Color.WHITE, _hit_flash)
	draw_circle(Vector2.ZERO, 14.0, color)
	draw_circle(Vector2.ZERO, 14.0, Color(0.10, 0.04, 0.05), false, 2.0)
	draw_circle(Vector2(-5.0, -3.0), 2.0, Color(1.0, 0.82, 0.45))
	draw_circle(Vector2(5.0, -3.0), 2.0, Color(1.0, 0.82, 0.45))

	var health_ratio: float = clampf(health / max_health, 0.0, 1.0)
	draw_rect(Rect2(Vector2(-13.0, -23.0), Vector2(26.0, 3.0)), Color(0.05, 0.04, 0.04, 0.85), true)
	draw_rect(Rect2(Vector2(-13.0, -23.0), Vector2(26.0 * health_ratio, 3.0)), Color(0.92, 0.32, 0.24), true)
