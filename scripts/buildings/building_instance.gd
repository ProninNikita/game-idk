extends StaticBody2D
class_name BuildingInstance

signal craft_completed(station: Node, recipe: Dictionary)
signal crafting_changed(station: Node)

const CRAFT_DURATION: float = 10.0
const STATION_RECIPES: Dictionary = {
	&"furnace": [
		{
			"id": &"coal_from_wood",
			"display_name": "Coal",
			"inputs": {&"wood": 2},
			"output_item_id": &"coal",
			"output_amount": 1,
			"duration": CRAFT_DURATION,
		},
		{
			"id": &"iron_ingot_from_ore",
			"display_name": "Iron Ingot",
			"inputs": {&"ore": 1, &"coal": 1},
			"output_item_id": &"iron_ingot",
			"output_amount": 1,
			"duration": CRAFT_DURATION,
		},
	],
	&"forge": [
		{
			"id": &"iron_armor",
			"display_name": "Iron Armor",
			"inputs": {&"iron_ingot": 10},
			"output_item_id": &"iron_armor",
			"output_amount": 1,
			"duration": CRAFT_DURATION,
		},
	],
	&"workbench": [
		{
			"id": &"fence",
			"display_name": "Fence",
			"inputs": {&"wood": 5},
			"output_item_id": &"fence",
			"output_amount": 1,
			"duration": CRAFT_DURATION,
		},
	],
}

var building_id: StringName = &"building"
var display_name: String = "Building"
var footprint: Vector2i = Vector2i.ONE
var grid_position: Vector2i = Vector2i.ZERO
var tile_size: int = 32
var debug_color: Color = Color(0.55, 0.52, 0.48)
var _active_recipe_id: StringName = &""
var _craft_time_left: float = 0.0
var _craft_duration: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("buildings")
	set_process(false)
	_apply_collision_shape()
	queue_redraw()


func _process(delta: float) -> void:
	if _active_recipe_id == &"":
		set_process(false)
		return

	_craft_time_left = maxf(0.0, _craft_time_left - delta)
	queue_redraw()

	if _craft_time_left > 0.0:
		return

	var recipe: Dictionary = get_recipe(_active_recipe_id)
	var completed_recipe: Dictionary = recipe.duplicate(true)
	_active_recipe_id = &""
	_craft_time_left = 0.0
	_craft_duration = 0.0
	set_process(false)
	crafting_changed.emit(self)
	craft_completed.emit(self, completed_recipe)


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


func has_station_recipes() -> bool:
	return not get_recipes().is_empty()


func get_recipes() -> Array:
	if not STATION_RECIPES.has(building_id):
		return []
	return STATION_RECIPES[building_id] as Array


func get_recipe(recipe_id: StringName) -> Dictionary:
	for recipe_value: Variant in get_recipes():
		var recipe: Dictionary = recipe_value as Dictionary
		if StringName(recipe.get("id", &"")) == recipe_id:
			return recipe
	return {}


func is_crafting() -> bool:
	return _active_recipe_id != &""


func start_craft(recipe_id: StringName) -> bool:
	if is_crafting():
		return false

	var recipe: Dictionary = get_recipe(recipe_id)
	if recipe.is_empty():
		return false

	_active_recipe_id = recipe_id
	_craft_duration = float(recipe.get("duration", CRAFT_DURATION))
	_craft_time_left = _craft_duration
	set_process(true)
	crafting_changed.emit(self)
	queue_redraw()
	return true


func get_craft_progress() -> float:
	if _active_recipe_id == &"" or _craft_duration <= 0.0:
		return 0.0
	return clampf(1.0 - (_craft_time_left / _craft_duration), 0.0, 1.0)


func get_station_snapshot() -> Dictionary:
	var recipes: Array = []
	for recipe_value: Variant in get_recipes():
		var recipe: Dictionary = recipe_value as Dictionary
		recipes.append(recipe.duplicate(true))

	return {
		"building_id": building_id,
		"display_name": display_name,
		"recipes": recipes,
		"active_recipe_id": _active_recipe_id,
		"craft_time_left": _craft_time_left,
		"craft_duration": _craft_duration,
		"craft_progress": get_craft_progress(),
	}


func get_output_drop_position() -> Vector2:
	var half_size: Vector2 = Vector2(float(footprint.x * tile_size), float(footprint.y * tile_size)) * 0.5
	return global_position + Vector2(0.0, half_size.y + 20.0)


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
	elif building_id == &"forge":
		draw_rect(Rect2(Vector2(-18.0, -8.0), Vector2(36.0, 16.0)), Color(0.12, 0.12, 0.14), true)
		draw_rect(Rect2(Vector2(-12.0, -16.0), Vector2(24.0, 8.0)), Color(0.70, 0.72, 0.76), true)
		draw_circle(Vector2(0.0, 10.0), 6.0, Color(0.96, 0.48, 0.18))
	elif building_id == &"workbench":
		draw_rect(Rect2(Vector2(-22.0, -10.0), Vector2(44.0, 18.0)), Color(0.42, 0.24, 0.12), true)
		draw_line(Vector2(-16.0, 10.0), Vector2(-16.0, 22.0), Color(0.16, 0.09, 0.04), 3.0)
		draw_line(Vector2(16.0, 10.0), Vector2(16.0, 22.0), Color(0.16, 0.09, 0.04), 3.0)
		draw_circle(Vector2(12.0, -2.0), 4.0, Color(0.72, 0.74, 0.78))
	elif building_id == &"fence":
		draw_line(Vector2(-12.0, -12.0), Vector2(-12.0, 12.0), Color(0.20, 0.11, 0.05), 4.0)
		draw_line(Vector2(12.0, -12.0), Vector2(12.0, 12.0), Color(0.20, 0.11, 0.05), 4.0)
		draw_line(Vector2(-15.0, -5.0), Vector2(15.0, -5.0), Color(0.34, 0.20, 0.10), 4.0)
		draw_line(Vector2(-15.0, 7.0), Vector2(15.0, 7.0), Color(0.34, 0.20, 0.10), 4.0)

	if _active_recipe_id != &"":
		var progress_radius: float = maxf(size.x, size.y) * 0.38
		draw_arc(Vector2.ZERO, progress_radius, -PI * 0.5, -PI * 0.5 + TAU * get_craft_progress(), 24, Color(0.95, 0.78, 0.20), 4.0)
