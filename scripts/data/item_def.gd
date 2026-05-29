extends Resource
class_name ItemDef

@export var id: StringName
@export var save_id: StringName
@export var display_name: String
@export var stack_size: int = 99
@export var icon: Texture2D
@export var tags: Array[StringName] = []


func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"save_id": save_id,
		"display_name": display_name,
		"stack_size": stack_size,
		"icon": icon,
		"tags": tags.duplicate(),
	}
