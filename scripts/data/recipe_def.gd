extends Resource
class_name RecipeDef

@export var id: StringName
@export var save_id: StringName
@export var display_name: String
@export var inputs: Dictionary = {}
@export var outputs: Dictionary = {}
@export var craft_time: float = 10.0
@export var station_ids: Array[StringName] = []
@export var station_tags: Array[StringName] = []
@export var required_tech: StringName
@export var icon: Texture2D


func get_primary_output_item_id() -> StringName:
	for item_id_value: Variant in outputs.keys():
		return StringName(item_id_value)
	return &""


func get_primary_output_amount() -> int:
	var item_id: StringName = get_primary_output_item_id()
	if item_id == &"":
		return 0
	return int(outputs.get(item_id, 0))


func to_dictionary() -> Dictionary:
	var output_item_id: StringName = get_primary_output_item_id()
	var output_amount: int = get_primary_output_amount()
	return {
		"id": id,
		"save_id": save_id,
		"display_name": display_name,
		"inputs": inputs.duplicate(true),
		"outputs": outputs.duplicate(true),
		"output_item_id": output_item_id,
		"output_amount": output_amount,
		"craft_time": craft_time,
		"duration": craft_time,
		"station_ids": station_ids.duplicate(),
		"station_tags": station_tags.duplicate(),
		"required_tech": required_tech,
		"icon": icon,
	}
