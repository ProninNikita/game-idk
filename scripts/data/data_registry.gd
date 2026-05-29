extends RefCounted
class_name DataRegistry

const ITEM_DEF_SCRIPT: Script = preload("res://scripts/data/item_def.gd")
const RECIPE_DEF_SCRIPT: Script = preload("res://scripts/data/recipe_def.gd")
const BUILDING_DEF_SCRIPT: Script = preload("res://scripts/data/building_def.gd")
const RESOURCE_DEF_SCRIPT: Script = preload("res://scripts/data/resource_def.gd")

static var _loaded: bool = false
static var _items: Dictionary = {}
static var _resources: Dictionary = {}
static var _recipes: Dictionary = {}
static var _buildings: Dictionary = {}
static var _resource_order: Array[StringName] = []
static var _building_order: Array[StringName] = []
static var _recipes_by_station: Dictionary = {}


static func has_item(item_id: StringName) -> bool:
	_ensure_loaded()
	return _items.has(item_id)


static func get_item_def(item_id: StringName) -> Resource:
	_ensure_loaded()
	return _items.get(item_id, null) as Resource


static func get_item_definition(item_id: StringName) -> Dictionary:
	var item: Resource = get_item_def(item_id)
	if item == null:
		return {}
	return item.call("to_dictionary") as Dictionary


static func get_item_display_name(item_id: StringName) -> String:
	var item: Resource = get_item_def(item_id)
	if item == null or String(item.get("display_name")) == "":
		return String(item_id).replace("_", " ").capitalize()
	return String(item.get("display_name"))


static func get_item_stack_size(item_id: StringName, fallback: int = 99) -> int:
	var item: Resource = get_item_def(item_id)
	if item == null:
		return fallback
	return maxi(1, int(item.get("stack_size")))


static func format_item_amount(item_id: StringName, amount: int) -> String:
	return "%d %s" % [amount, get_item_display_name(item_id)]


static func has_resource(resource_id: StringName) -> bool:
	_ensure_loaded()
	return _resources.has(resource_id)


static func get_resource_def(resource_id: StringName) -> Resource:
	_ensure_loaded()
	return _resources.get(resource_id, null) as Resource


static func get_resource_definition(resource_id: StringName) -> Dictionary:
	var resource: Resource = get_resource_def(resource_id)
	if resource == null:
		return {}
	return resource.call("to_dictionary") as Dictionary


static func get_resource_definitions() -> Array[Dictionary]:
	_ensure_loaded()
	var definitions: Array[Dictionary] = []
	for resource_id: StringName in _resource_order:
		var resource: Resource = _resources.get(resource_id, null) as Resource
		if resource != null:
			definitions.append(resource.call("to_dictionary") as Dictionary)
	return definitions


static func has_building(building_id: StringName) -> bool:
	_ensure_loaded()
	return _buildings.has(building_id)


static func get_building_def(building_id: StringName) -> Resource:
	_ensure_loaded()
	return _buildings.get(building_id, null) as Resource


static func get_building_definition(building_id: StringName) -> Dictionary:
	var building: Resource = get_building_def(building_id)
	if building == null:
		return {}
	return building.call("to_dictionary") as Dictionary


static func get_building_definitions() -> Array[Dictionary]:
	_ensure_loaded()
	var definitions: Array[Dictionary] = []
	for building_id: StringName in _building_order:
		var building: Resource = _buildings.get(building_id, null) as Resource
		if building != null:
			definitions.append(building.call("to_dictionary") as Dictionary)
	return definitions


static func has_building_cost(building_id: StringName) -> bool:
	var building: Resource = get_building_def(building_id)
	return building != null and bool(building.get("has_build_cost"))


static func get_building_cost(building_id: StringName) -> Dictionary:
	var building: Resource = get_building_def(building_id)
	if building == null:
		return {}
	var build_cost: Dictionary = building.get("build_cost") as Dictionary
	return build_cost.duplicate(true)


static func get_recipe_def(recipe_id: StringName) -> Resource:
	_ensure_loaded()
	return _recipes.get(recipe_id, null) as Resource


static func get_recipe_definition(recipe_id: StringName) -> Dictionary:
	var recipe: Resource = get_recipe_def(recipe_id)
	if recipe == null:
		return {}
	return recipe.call("to_dictionary") as Dictionary


static func get_station_recipe_definitions(building_id: StringName) -> Array:
	_ensure_loaded()
	var recipes: Array = []
	var recipe_ids: Array = _recipes_by_station.get(building_id, []) as Array
	for recipe_id_value: Variant in recipe_ids:
		var recipe_id: StringName = StringName(recipe_id_value)
		var recipe: Resource = _recipes.get(recipe_id, null) as Resource
		if recipe != null:
			recipes.append(recipe.call("to_dictionary") as Dictionary)
	return recipes


static func format_cost(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for item_id_value: Variant in cost.keys():
		var item_id: StringName = StringName(item_id_value)
		parts.append(format_item_amount(item_id, int(cost[item_id_value])))
	return ", ".join(parts)


static func _ensure_loaded() -> void:
	if _loaded:
		return

	_register_item(_make_item(&"multitool_cutter", "Multitool Cutter", 1, [&"tool", &"starter", &"cutter"]))
	_register_item(_make_item(&"wood", "Wood", 99, [&"raw", &"fuel", &"building_material"]))
	_register_item(_make_item(&"stone", "Stone", 99, [&"raw", &"building_material"]))
	_register_item(_make_item(&"ore", "Ore", 99, [&"raw", &"smeltable"]))
	_register_item(_make_item(&"crop", "Wild Crop", 99, [&"raw", &"food"]))
	_register_item(_make_item(&"coal", "Coal", 99, [&"fuel", &"processed"]))
	_register_item(_make_item(&"iron_ingot", "Iron Ingot", 99, [&"processed", &"metal"]))
	_register_item(_make_item(&"iron_armor", "Iron Armor", 1, [&"equipment", &"armor"]))
	_register_item(_make_item(&"fence", "Fence", 99, [&"building_token"]))

	_register_resource(_make_resource(&"tree", "Tree", &"wood", 4, 3.0, 13.0, Color(0.23, 0.62, 0.25), [&"wood", &"plant"]))
	_register_resource(_make_resource(&"stone", "Stone", &"stone", 3, 4.0, 12.0, Color(0.49, 0.52, 0.55), [&"stone", &"rock"]))
	_register_resource(_make_resource(&"ore", "Ore", &"ore", 2, 5.0, 13.0, Color(0.34, 0.35, 0.43), [&"ore", &"rock"]))
	_register_resource(_make_resource(&"crop", "Wild Crop", &"crop", 2, 2.0, 10.0, Color(0.68, 0.83, 0.25), [&"plant", &"food"]))

	_register_recipe(_make_recipe(&"coal_from_wood", "Coal", {&"wood": 2}, {&"coal": 1}, 10.0, [&"furnace"]))
	_register_recipe(_make_recipe(&"iron_ingot_from_ore", "Iron Ingot", {&"ore": 1, &"coal": 1}, {&"iron_ingot": 1}, 10.0, [&"furnace"]))
	_register_recipe(_make_recipe(&"iron_armor", "Iron Armor", {&"iron_ingot": 10}, {&"iron_armor": 1}, 10.0, [&"forge"]))
	_register_recipe(_make_recipe(&"fence", "Fence", {&"wood": 5}, {&"fence": 1}, 10.0, [&"workbench"]))

	_register_building(_make_building(&"furnace", "Furnace", _load_building_scene("res://scenes/buildings/furnace.tscn"), Vector2i(2, 2), {&"stone": 2, &"wood": 1}, 24.0, Color(0.48, 0.42, 0.36), [&"coal_from_wood", &"iron_ingot_from_ore"], [&"station", &"smelting"]))
	_register_building(_make_building(&"forge", "Forge", _load_building_scene("res://scenes/buildings/forge.tscn"), Vector2i(2, 2), {&"stone": 4, &"ore": 2}, 28.0, Color(0.36, 0.38, 0.42), [&"iron_armor"], [&"station", &"equipment"]))
	_register_building(_make_building(&"workbench", "Workbench", _load_building_scene("res://scenes/buildings/workbench.tscn"), Vector2i(2, 2), {&"wood": 2, &"stone": 1}, 20.0, Color(0.48, 0.31, 0.17), [&"fence"], [&"station", &"crafting"]))
	_register_building(_make_building(&"fence", "Fence", _load_building_scene("res://scenes/buildings/fence.tscn"), Vector2i(1, 1), {&"fence": 1}, 8.0, Color(0.39, 0.24, 0.12), [], [&"defense", &"wall"]))

	_loaded = true


static func _make_item(item_id: StringName, display_name: String, stack_size: int, tags: Array) -> Resource:
	var item: Resource = ITEM_DEF_SCRIPT.new() as Resource
	item.set("id", item_id)
	item.set("save_id", item_id)
	item.set("display_name", display_name)
	item.set("stack_size", stack_size)
	item.set("tags", _copy_string_name_array(tags))
	return item


static func _register_item(item: Resource) -> void:
	var item_id: StringName = StringName(item.get("id"))
	if item_id == &"":
		return
	_items[item_id] = item


static func _make_resource(resource_id: StringName, display_name: String, drop_item_id: StringName, drop_amount: int, max_health: float, collision_radius: float, color: Color, tags: Array) -> Resource:
	var resource: Resource = RESOURCE_DEF_SCRIPT.new() as Resource
	resource.set("id", resource_id)
	resource.set("save_id", resource_id)
	resource.set("display_name", display_name)
	resource.set("drop_item_id", drop_item_id)
	resource.set("drop_amount", drop_amount)
	resource.set("max_health", max_health)
	resource.set("collision_radius", collision_radius)
	resource.set("color", color)
	resource.set("tags", _copy_string_name_array(tags))
	return resource


static func _register_resource(resource: Resource) -> void:
	var resource_id: StringName = StringName(resource.get("id"))
	if resource_id == &"":
		return
	var drop_item_id: StringName = StringName(resource.get("drop_item_id"))
	if drop_item_id == &"" or not _items.has(drop_item_id):
		push_warning("Resource definition rejected because it references an unknown drop item id: %s" % String(resource_id))
		return
	_resources[resource_id] = resource
	_resource_order.append(resource_id)


static func _make_recipe(recipe_id: StringName, display_name: String, inputs: Dictionary, outputs: Dictionary, craft_time: float, station_ids: Array) -> Resource:
	var recipe: Resource = RECIPE_DEF_SCRIPT.new() as Resource
	recipe.set("id", recipe_id)
	recipe.set("save_id", recipe_id)
	recipe.set("display_name", display_name)
	recipe.set("inputs", inputs.duplicate(true))
	recipe.set("outputs", outputs.duplicate(true))
	recipe.set("craft_time", craft_time)
	recipe.set("station_ids", _copy_string_name_array(station_ids))
	return recipe


static func _register_recipe(recipe: Resource) -> void:
	var recipe_id: StringName = StringName(recipe.get("id"))
	if recipe_id == &"":
		return
	var inputs: Dictionary = recipe.get("inputs") as Dictionary
	var outputs: Dictionary = recipe.get("outputs") as Dictionary
	if not _has_known_item_amounts(inputs) or not _has_known_item_amounts(outputs):
		push_warning("Recipe definition rejected because it references an unknown item id: %s" % String(recipe_id))
		return
	_recipes[recipe_id] = recipe
	var station_ids: Array = recipe.get("station_ids") as Array
	for station_id_value: Variant in station_ids:
		var station_id: StringName = StringName(station_id_value)
		if not _recipes_by_station.has(station_id):
			_recipes_by_station[station_id] = []
		var station_recipes: Array = _recipes_by_station[station_id] as Array
		station_recipes.append(recipe_id)


static func _make_building(building_id: StringName, display_name: String, scene: PackedScene, footprint: Vector2i, build_cost: Dictionary, max_health: float, color: Color, station_recipe_ids: Array, tags: Array) -> Resource:
	var building: Resource = BUILDING_DEF_SCRIPT.new() as Resource
	building.set("id", building_id)
	building.set("save_id", building_id)
	building.set("display_name", display_name)
	building.set("scene", scene)
	building.set("footprint", footprint)
	building.set("has_build_cost", true)
	building.set("build_cost", build_cost.duplicate(true))
	building.set("max_health", max_health)
	building.set("color", color)
	building.set("station_recipe_ids", _copy_string_name_array(station_recipe_ids))
	building.set("tags", _copy_string_name_array(tags))
	return building


static func _register_building(building: Resource) -> void:
	var building_id: StringName = StringName(building.get("id"))
	if building_id == &"":
		return
	var has_build_cost: bool = bool(building.get("has_build_cost"))
	var build_cost: Dictionary = building.get("build_cost") as Dictionary
	if has_build_cost and not _has_known_item_amounts(build_cost):
		push_warning("Building definition rejected because it references an unknown item id: %s" % String(building_id))
		return
	_buildings[building_id] = building
	_building_order.append(building_id)


static func _load_building_scene(path: String) -> PackedScene:
	return load(path) as PackedScene


static func _copy_string_name_array(values: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	for value: Variant in values:
		result.append(StringName(value))
	return result


static func _has_known_item_amounts(amounts: Dictionary) -> bool:
	for item_id_value: Variant in amounts.keys():
		var item_id: StringName = StringName(item_id_value)
		if not _items.has(item_id):
			return false
	return true
