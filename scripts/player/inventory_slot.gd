extends RefCounted
class_name InventorySlot

const ItemStackModel = preload("res://scripts/player/item_stack.gd")

var stack = null
var locked: bool = false
var slot_type: StringName = &""


func is_empty() -> bool:
	return stack == null or stack.is_empty()


func get_item_id() -> StringName:
	if is_empty():
		return &""
	return stack.item_id


func get_amount() -> int:
	if is_empty():
		return 0
	return stack.amount


func set_item(item_id: StringName, amount: int, new_locked: bool = false, new_slot_type: StringName = &"") -> void:
	if amount <= 0 or item_id == &"":
		clear()
		return

	stack = ItemStackModel.new(item_id, amount)
	locked = new_locked
	slot_type = new_slot_type


func set_amount(amount: int) -> void:
	if stack == null:
		return
	if amount <= 0:
		clear()
		return
	stack.amount = amount


func clear() -> void:
	stack = null
	locked = false
	slot_type = &""


func to_dictionary() -> Dictionary:
	if is_empty():
		return {}

	var data: Dictionary = stack.to_dictionary()
	if locked:
		data["locked"] = true
	if slot_type != &"":
		data["slot_type"] = slot_type
	return data
