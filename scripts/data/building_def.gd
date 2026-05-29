extends Resource
class_name BuildingDef

@export var id: StringName
@export var save_id: StringName
@export var display_name: String
@export var scene: PackedScene
@export var footprint: Vector2i = Vector2i.ONE
@export var has_build_cost: bool = true
@export var build_cost: Dictionary = {}
@export var max_health: float = 20.0
@export var tags: Array[StringName] = []
@export var station_recipe_ids: Array[StringName] = []
@export var icon: Texture2D
@export var color: Color = Color(0.48, 0.42, 0.36)


func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"save_id": save_id,
		"display_name": display_name,
		"scene": scene,
		"footprint": footprint,
		"has_build_cost": has_build_cost,
		"cost": build_cost.duplicate(true),
		"build_cost": build_cost.duplicate(true),
		"max_health": max_health,
		"tags": tags.duplicate(),
		"station_recipe_ids": station_recipe_ids.duplicate(),
		"icon": icon,
		"color": color,
	}
