extends Node
class_name InventoryComponent

signal changed(items: Dictionary)

var items: Dictionary = {}


func add_item(item_id: StringName, amount: int) -> int:
	if amount <= 0:
		return 0

	items[item_id] = int(items.get(item_id, 0)) + amount
	changed.emit(get_items())
	return amount


func remove_item(item_id: StringName, amount: int) -> int:
	if amount <= 0 or not items.has(item_id):
		return 0

	var removed: int = mini(amount, int(items[item_id]))
	var remaining: int = int(items[item_id]) - removed
	if remaining <= 0:
		items.erase(item_id)
	else:
		items[item_id] = remaining

	changed.emit(get_items())
	return removed


func get_count(item_id: StringName) -> int:
	return int(items.get(item_id, 0))


func get_items() -> Dictionary:
	return items.duplicate()


func is_empty() -> bool:
	return items.is_empty()

