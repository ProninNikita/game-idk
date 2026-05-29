extends Resource
class_name ResourceDef

@export var id: StringName
@export var save_id: StringName
@export var display_name: String
@export var drop_item_id: StringName
@export var drop_amount: int = 1
@export var max_health: float = 3.0
@export var collision_radius: float = 12.0
@export var color: Color = Color(0.35, 0.75, 0.28)
@export var tags: Array[StringName] = []
@export var icon: Texture2D


func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"save_id": save_id,
		"display_name": display_name,
		"drop_item_id": drop_item_id,
		"drop_amount": drop_amount,
		"max_health": max_health,
		"collision_radius": collision_radius,
		"radius": collision_radius,
		"color": color,
		"tags": tags.duplicate(),
		"icon": icon,
	}
