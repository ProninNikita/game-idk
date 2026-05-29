extends RefCounted
class_name ItemStack

var item_id: StringName = &""
var amount: int = 0


func _init(new_item_id: StringName = &"", new_amount: int = 0) -> void:
	item_id = new_item_id
	amount = maxi(new_amount, 0)


func is_empty() -> bool:
	return item_id == &"" or amount <= 0


func duplicate_stack() -> RefCounted:
	return get_script().new(item_id, amount)


func to_dictionary() -> Dictionary:
	if is_empty():
		return {}
	return {
		"item_id": item_id,
		"amount": amount,
	}
