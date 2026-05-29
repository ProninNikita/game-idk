extends StaticBody2D
class_name BuildingInstance

const DataRegistry = preload("res://scripts/data/data_registry.gd")
const InventorySlotModel = preload("res://scripts/player/inventory_slot.gd")

signal craft_completed(station: Node, recipe: Dictionary)
signal crafting_changed(station: Node)
signal output_overflow_requested(station: Node, item_id: StringName, amount: int, drop_position: Vector2, color: Color)
signal destroyed(building: Node, refund_items: Dictionary)

const DEFAULT_CRAFT_DURATION: float = 10.0
const DEFAULT_STATION_SLOT_COUNT: int = 6

@export var definition_id: StringName = &"building"
@export var input_slot_count: int = DEFAULT_STATION_SLOT_COUNT
@export var output_slot_count: int = DEFAULT_STATION_SLOT_COUNT

var building_id: StringName = &"building"
var display_name: String = "Building"
var footprint: Vector2i = Vector2i.ONE
var grid_position: Vector2i = Vector2i.ZERO
var tile_size: int = 32
var debug_color: Color = Color(0.55, 0.52, 0.48)
var max_health: float = 20.0
var health: float = 20.0
var collision_radius: float = 24.0
var _active_recipe_id: StringName = &""
var _active_recipe: Dictionary = {}
var _craft_time_left: float = 0.0
var _craft_duration: float = 0.0
var _station_state: StringName = &"ready"
var _input_slots: Array[RefCounted] = []
var _output_slots: Array[RefCounted] = []

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("buildings")
	_apply_definition_defaults()
	_ensure_station_slots()
	set_process(false)
	_apply_collision_shape()
	queue_redraw()


func _process(delta: float) -> void:
	tick_station(delta)


func tick_station(delta: float) -> void:
	if _active_recipe_id == &"":
		return

	_craft_time_left = maxf(0.0, _craft_time_left - delta)
	queue_redraw()

	if _craft_time_left > 0.0:
		return

	var completed_recipe: Dictionary = _active_recipe.duplicate(true)
	if completed_recipe.is_empty():
		completed_recipe = get_recipe(_active_recipe_id)

	_add_recipe_outputs(completed_recipe)
	_active_recipe_id = &""
	_active_recipe = {}
	_craft_time_left = 0.0
	_craft_duration = 0.0
	_station_state = &"ready"
	crafting_changed.emit(self)
	craft_completed.emit(self, completed_recipe)


func setup(new_id: StringName, new_display_name: String, new_grid_position: Vector2i, new_footprint: Vector2i, new_tile_size: int, color: Color) -> void:
	definition_id = new_id
	building_id = new_id
	display_name = new_display_name
	grid_position = new_grid_position
	footprint = new_footprint
	tile_size = new_tile_size
	debug_color = color
	_apply_health_from_definition()
	_update_collision_radius()
	position = Vector2(
		float(grid_position.x * tile_size) + float(footprint.x * tile_size) * 0.5,
		float(grid_position.y * tile_size) + float(footprint.y * tile_size) * 0.5
	)

	if is_inside_tree():
		_apply_collision_shape()
		queue_redraw()


func _apply_definition_defaults() -> void:
	if definition_id == &"" or definition_id == &"building":
		return
	if building_id != &"building":
		return

	var definition: Dictionary = DataRegistry.get_building_definition(definition_id)
	if definition.is_empty():
		return

	building_id = definition_id
	display_name = String(definition.get("display_name", String(definition_id)))
	footprint = definition.get("footprint", Vector2i.ONE) as Vector2i
	debug_color = definition.get("color", debug_color) as Color
	_apply_health_from_definition(definition)
	_update_collision_radius()


func has_station_recipes() -> bool:
	return not get_recipes().is_empty()


func get_recipes() -> Array:
	return DataRegistry.get_station_recipe_definitions(building_id)


func get_recipe(recipe_id: StringName) -> Dictionary:
	for recipe_value: Variant in get_recipes():
		var recipe: Dictionary = recipe_value as Dictionary
		if StringName(recipe.get("id", &"")) == recipe_id:
			return recipe
	return {}


func is_crafting() -> bool:
	return _active_recipe_id != &""


func hit(damage: float, tool_tags: Array) -> Dictionary:
	if damage <= 0.0:
		return {}
	if tool_tags.is_empty():
		return {}

	health = maxf(0.0, health - damage)
	queue_redraw()
	if health > 0.0:
		return {}

	destroyed.emit(self, _get_refund_items())
	queue_free()
	return {}


func start_craft(recipe_id: StringName) -> bool:
	if is_crafting():
		_station_state = &"working"
		return false

	var recipe: Dictionary = get_recipe(recipe_id)
	if recipe.is_empty():
		_station_state = &"unknown_recipe"
		crafting_changed.emit(self)
		return false
	if not has_recipe_inputs(recipe_id):
		_station_state = &"missing_input"
		crafting_changed.emit(self)
		return false
	if not can_store_recipe_outputs(recipe_id):
		_station_state = &"blocked_output"
		crafting_changed.emit(self)
		return false
	if not _try_remove_from_slots(_input_slots, recipe.get("inputs", {}) as Dictionary):
		_station_state = &"missing_input"
		crafting_changed.emit(self)
		return false

	_active_recipe_id = recipe_id
	_active_recipe = recipe.duplicate(true)
	_craft_duration = float(recipe.get("duration", DEFAULT_CRAFT_DURATION))
	_craft_time_left = _craft_duration
	_station_state = &"working"
	crafting_changed.emit(self)
	queue_redraw()
	return true


func get_craft_progress() -> float:
	if _active_recipe_id == &"" or _craft_duration <= 0.0:
		return 0.0
	return clampf(1.0 - (_craft_time_left / _craft_duration), 0.0, 1.0)


func get_station_snapshot() -> Dictionary:
	_ensure_station_slots()
	var recipes: Array = []
	for recipe_value: Variant in get_recipes():
		var recipe: Dictionary = recipe_value as Dictionary
		recipes.append(recipe.duplicate(true))

	return {
		"building_id": building_id,
		"display_name": display_name,
		"recipes": recipes,
		"input_slots": _slots_to_dictionaries(_input_slots),
		"output_slots": _slots_to_dictionaries(_output_slots),
		"input_items": _summarize_slots(_input_slots),
		"output_items": _summarize_slots(_output_slots),
		"active_recipe_id": _active_recipe_id,
		"craft_time_left": _craft_time_left,
		"craft_duration": _craft_duration,
		"craft_progress": get_craft_progress(),
		"station_state": _station_state,
		"station_state_label": get_station_state_label(),
		"can_collect_outputs": has_output_items(),
	}


func get_station_state_label() -> String:
	if _station_state == &"working":
		return "Crafting"
	if _station_state == &"missing_input":
		return "Missing input"
	if _station_state == &"blocked_output":
		return "Output full"
	if _station_state == &"unknown_recipe":
		return "Unknown recipe"
	return "Ready"


func has_recipe_inputs(recipe_id: StringName) -> bool:
	var recipe: Dictionary = get_recipe(recipe_id)
	if recipe.is_empty():
		return false
	return _has_items_in_slots(_input_slots, recipe.get("inputs", {}) as Dictionary)


func can_store_recipe_outputs(recipe_id: StringName) -> bool:
	var recipe: Dictionary = get_recipe(recipe_id)
	if recipe.is_empty():
		return false
	return _get_acceptable_amounts(_output_slots, recipe.get("outputs", {}) as Dictionary)


func get_missing_recipe_inputs(recipe_id: StringName) -> Dictionary:
	var recipe: Dictionary = get_recipe(recipe_id)
	if recipe.is_empty():
		return {}

	var missing: Dictionary = {}
	var inputs: Dictionary = recipe.get("inputs", {}) as Dictionary
	for item_id_value: Variant in inputs.keys():
		var item_id: StringName = StringName(item_id_value)
		var required: int = int(inputs[item_id_value])
		var available: int = _get_slot_item_count(_input_slots, item_id)
		var missing_amount: int = required - available
		if missing_amount > 0:
			missing[item_id] = missing_amount
	return missing


func can_accept_input_items(amounts: Dictionary) -> bool:
	_ensure_station_slots()
	return _get_acceptable_amounts(_input_slots, amounts)


func add_input_items(amounts: Dictionary) -> Dictionary:
	_ensure_station_slots()
	var leftover: Dictionary = {}
	for item_id_value: Variant in amounts.keys():
		var item_id: StringName = StringName(item_id_value)
		var amount: int = int(amounts[item_id_value])
		if amount <= 0:
			continue
		var remaining: int = _add_to_slots(_input_slots, item_id, amount)
		if remaining > 0:
			leftover[item_id] = remaining
	if leftover.size() < amounts.size():
		crafting_changed.emit(self)
	return leftover


func has_output_items() -> bool:
	_ensure_station_slots()
	for slot in _output_slots:
		if not slot.is_empty():
			return true
	return false


func collect_outputs_to_inventory(target_inventory: InventoryComponent) -> Dictionary:
	_ensure_station_slots()
	var collected: Dictionary = {}
	if target_inventory == null:
		return collected

	for slot in _output_slots:
		if slot.is_empty():
			continue

		var item_id: StringName = slot.get_item_id()
		var amount: int = slot.get_amount()
		var acceptable: int = target_inventory.get_acceptable_amount(item_id, amount)
		if acceptable <= 0:
			continue

		var added: int = target_inventory.add_item(item_id, acceptable)
		if added <= 0:
			continue

		slot.set_amount(amount - added)
		collected[item_id] = int(collected.get(item_id, 0)) + added

	if not collected.is_empty():
		if _station_state == &"blocked_output":
			_station_state = &"ready"
		crafting_changed.emit(self)
	return collected


func add_output_items(amounts: Dictionary) -> Dictionary:
	_ensure_station_slots()
	var leftover: Dictionary = {}
	for item_id_value: Variant in amounts.keys():
		var item_id: StringName = StringName(item_id_value)
		var amount: int = int(amounts[item_id_value])
		var remaining: int = _add_to_slots(_output_slots, item_id, amount)
		if remaining > 0:
			leftover[item_id] = remaining
			output_overflow_requested.emit(self, item_id, remaining, get_output_drop_position(), _get_item_debug_color(item_id))
	if not amounts.is_empty():
		crafting_changed.emit(self)
	return leftover


func get_input_slots_snapshot() -> Array[Dictionary]:
	_ensure_station_slots()
	return _slots_to_dictionaries(_input_slots)


func get_output_slots_snapshot() -> Array[Dictionary]:
	_ensure_station_slots()
	return _slots_to_dictionaries(_output_slots)


func get_output_drop_position() -> Vector2:
	var half_size: Vector2 = Vector2(float(footprint.x * tile_size), float(footprint.y * tile_size)) * 0.5
	return global_position + Vector2(0.0, half_size.y + 20.0)


func _ensure_station_slots() -> void:
	if not has_station_recipes():
		return
	_ensure_slot_array(_input_slots, input_slot_count)
	_ensure_slot_array(_output_slots, output_slot_count)


func _ensure_slot_array(slots: Array[RefCounted], target_count: int) -> void:
	var count: int = maxi(target_count, 1)
	while slots.size() < count:
		slots.append(InventorySlotModel.new())
	while slots.size() > count:
		var slot = slots[slots.size() - 1]
		if not slot.is_empty():
			return
		slots.pop_back()


func _slots_to_dictionaries(slots: Array[RefCounted]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for slot in slots:
		result.append(slot.to_dictionary())
	return result


func _summarize_slots(slots: Array[RefCounted]) -> Dictionary:
	var summary: Dictionary = {}
	for slot in slots:
		if slot.is_empty():
			continue
		var item_id: StringName = slot.get_item_id()
		summary[item_id] = int(summary.get(item_id, 0)) + slot.get_amount()
	return summary


func _has_items_in_slots(slots: Array[RefCounted], amounts: Dictionary) -> bool:
	for item_id_value: Variant in amounts.keys():
		var item_id: StringName = StringName(item_id_value)
		if _get_slot_item_count(slots, item_id) < int(amounts[item_id_value]):
			return false
	return true


func _get_slot_item_count(slots: Array[RefCounted], item_id: StringName) -> int:
	var total: int = 0
	for slot in slots:
		if slot.is_empty():
			continue
		if slot.get_item_id() == item_id:
			total += slot.get_amount()
	return total


func _get_acceptable_amounts(slots: Array[RefCounted], amounts: Dictionary) -> bool:
	var planned: Array[Dictionary] = _slots_to_dictionaries(slots)
	for item_id_value: Variant in amounts.keys():
		var item_id: StringName = StringName(item_id_value)
		var amount: int = int(amounts[item_id_value])
		var remaining: int = _simulate_add_to_slot_dictionaries(planned, item_id, amount)
		if remaining > 0:
			return false
	return true


func _simulate_add_to_slot_dictionaries(slots: Array[Dictionary], item_id: StringName, amount: int) -> int:
	var remaining: int = amount
	var max_stack: int = DataRegistry.get_item_stack_size(item_id, 99)
	for slot: Dictionary in slots:
		if remaining <= 0:
			break
		if slot.is_empty():
			continue
		if StringName(slot.get("item_id", &"")) != item_id:
			continue
		var current_amount: int = int(slot.get("amount", 0))
		var accepted: int = mini(remaining, max_stack - current_amount)
		if accepted <= 0:
			continue
		slot["amount"] = current_amount + accepted
		remaining -= accepted

	for slot: Dictionary in slots:
		if remaining <= 0:
			break
		if not slot.is_empty():
			continue
		var accepted: int = mini(remaining, max_stack)
		slot["item_id"] = item_id
		slot["amount"] = accepted
		remaining -= accepted
	return remaining


func _add_to_slots(slots: Array[RefCounted], item_id: StringName, amount: int) -> int:
	var remaining: int = amount
	var max_stack: int = DataRegistry.get_item_stack_size(item_id, 99)
	for slot in slots:
		if remaining <= 0:
			break
		if slot.is_empty():
			continue
		if slot.get_item_id() != item_id:
			continue
		var current_amount: int = slot.get_amount()
		var accepted: int = mini(remaining, max_stack - current_amount)
		if accepted <= 0:
			continue
		slot.set_amount(current_amount + accepted)
		remaining -= accepted

	for slot in slots:
		if remaining <= 0:
			break
		if not slot.is_empty():
			continue
		var accepted: int = mini(remaining, max_stack)
		slot.set_item(item_id, accepted)
		remaining -= accepted
	return remaining


func _try_remove_from_slots(slots: Array[RefCounted], amounts: Dictionary) -> bool:
	if not _has_items_in_slots(slots, amounts):
		return false

	for item_id_value: Variant in amounts.keys():
		var item_id: StringName = StringName(item_id_value)
		var remaining: int = int(amounts[item_id_value])
		for slot in slots:
			if remaining <= 0:
				break
			if slot.is_empty():
				continue
			if slot.get_item_id() != item_id:
				continue
			var current_amount: int = slot.get_amount()
			var taken: int = mini(remaining, current_amount)
			slot.set_amount(current_amount - taken)
			remaining -= taken
	return true


func _add_recipe_outputs(recipe: Dictionary) -> void:
	var outputs: Dictionary = recipe.get("outputs", {}) as Dictionary
	add_output_items(outputs)


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
		_update_collision_radius()


func _apply_health_from_definition(definition: Dictionary = {}) -> void:
	var source: Dictionary = definition
	if source.is_empty() and building_id != &"":
		source = DataRegistry.get_building_definition(building_id)
	max_health = float(source.get("max_health", max_health))
	health = max_health


func _update_collision_radius() -> void:
	collision_radius = maxf(float(footprint.x * tile_size), float(footprint.y * tile_size)) * 0.5


func _get_refund_items() -> Dictionary:
	var cost: Dictionary = DataRegistry.get_building_cost(building_id)
	var refund: Dictionary = {}
	for item_id_value: Variant in cost.keys():
		var amount: int = int(cost[item_id_value])
		if amount <= 0:
			continue
		refund[StringName(item_id_value)] = maxi(1, ceili(float(amount) * 0.5))
	return refund


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

	if health < max_health:
		var health_ratio: float = clampf(health / max_health, 0.0, 1.0)
		var bar_width: float = size.x * 0.68
		var bar_y: float = -size.y * 0.5 - 10.0
		draw_rect(Rect2(Vector2(-bar_width * 0.5, bar_y), Vector2(bar_width, 4.0)), Color(0.05, 0.04, 0.04, 0.85), true)
		draw_rect(Rect2(Vector2(-bar_width * 0.5, bar_y), Vector2(bar_width * health_ratio, 4.0)), Color(0.85, 0.42, 0.24), true)
