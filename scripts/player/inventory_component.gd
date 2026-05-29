extends Node
class_name InventoryComponent

signal changed(items: Dictionary)

const DataRegistry = preload("res://scripts/data/data_registry.gd")
const InventorySlotModel = preload("res://scripts/player/inventory_slot.gd")
const STARTING_TOOL_ID: StringName = &"multitool_cutter"
const LEGACY_STARTING_TOOL_ID: StringName = &"pickaxe"

@export var slot_count: int = 27
@export var toolbelt_slot_count: int = 9
@export var default_stack_size: int = 99

var slots: Array[RefCounted] = []
var _last_preserved_shrink_target: int = -1


func _ready() -> void:
	_ensure_slots()
	_ensure_starting_tool()


func add_item(item_id: StringName, amount: int) -> int:
	var leftover: int = add_item_with_leftover(item_id, amount)
	return amount - leftover


func add_item_with_leftover(item_id: StringName, amount: int) -> int:
	if amount <= 0:
		return 0
	if not DataRegistry.has_item(item_id):
		push_warning("Unknown item id rejected by inventory: %s" % String(item_id))
		return amount

	_ensure_slots()
	_ensure_starting_tool()

	var remaining: int = amount
	var max_stack: int = get_stack_size(item_id)
	var toolbelt_end: int = mini(toolbelt_slot_count, slots.size())

	remaining = _merge_into_existing_slots(item_id, remaining, max_stack, 0, toolbelt_end)
	remaining = _fill_empty_slots(item_id, remaining, max_stack, 0, toolbelt_end)
	remaining = _merge_into_existing_slots(item_id, remaining, max_stack, toolbelt_end, slots.size())
	remaining = _fill_empty_slots(item_id, remaining, max_stack, toolbelt_end, slots.size())

	changed.emit(get_items())
	return remaining


func remove_item(item_id: StringName, amount: int) -> int:
	if amount <= 0:
		return 0
	if not DataRegistry.has_item(item_id):
		return 0

	_ensure_slots()
	_ensure_starting_tool()
	return _remove_item_internal(item_id, amount, true)


func can_remove_items(cost: Dictionary) -> bool:
	_ensure_slots()
	_ensure_starting_tool()

	for item_id_value: Variant in cost.keys():
		var item_id: StringName = StringName(item_id_value)
		var required: int = int(cost[item_id_value])
		if required <= 0:
			continue
		if not DataRegistry.has_item(item_id):
			return false
		if _get_removable_count(item_id) < required:
			return false

	return true


func try_remove_items(cost: Dictionary) -> bool:
	if not can_remove_items(cost):
		return false

	for item_id_value: Variant in cost.keys():
		var item_id: StringName = StringName(item_id_value)
		var required: int = int(cost[item_id_value])
		if required > 0:
			_remove_item_internal(item_id, required, false)

	changed.emit(get_items())
	return true


func _remove_item_internal(item_id: StringName, amount: int, emit_changed: bool) -> int:
	if amount <= 0:
		return 0

	var remaining: int = amount
	var removed: int = 0

	for i: int in range(slots.size()):
		if remaining <= 0:
			break

		var slot = slots[i]
		if slot.is_empty():
			continue
		if slot.locked:
			continue
		if slot.get_item_id() != item_id:
			continue

		var slot_amount: int = slot.get_amount()
		var take: int = mini(remaining, slot_amount)
		slot_amount -= take
		remaining -= take
		removed += take

		slot.set_amount(slot_amount)

	if emit_changed:
		changed.emit(get_items())
	return removed


func _get_removable_count(item_id: StringName) -> int:
	var total: int = 0
	for slot in slots:
		if slot.is_empty():
			continue
		if slot.locked:
			continue
		if slot.get_item_id() == item_id:
			total += slot.get_amount()
	return total


func get_count(item_id: StringName) -> int:
	var total: int = 0
	for slot in slots:
		if slot.is_empty():
			continue
		if slot.get_item_id() == item_id:
			total += slot.get_amount()
	return total


func get_items() -> Dictionary:
	var summary: Dictionary = {}
	for slot in slots:
		if slot.is_empty():
			continue
		var item_id: StringName = slot.get_item_id()
		if item_id == &"":
			continue
		summary[item_id] = int(summary.get(item_id, 0)) + slot.get_amount()
	return summary


func get_slots() -> Array[Dictionary]:
	_ensure_slots()
	_ensure_starting_tool()
	var copy: Array[Dictionary] = []
	for slot in slots:
		copy.append(slot.to_dictionary())
	return copy


func can_accept_item(item_id: StringName, amount: int = 1) -> bool:
	return get_acceptable_amount(item_id, amount) > 0


func get_acceptable_amount(item_id: StringName, amount: int) -> int:
	if amount <= 0:
		return 0
	if not DataRegistry.has_item(item_id):
		return 0

	_ensure_slots()
	_ensure_starting_tool()
	var remaining: int = amount
	var max_stack: int = get_stack_size(item_id)

	for slot in slots:
		if remaining <= 0:
			break
		if slot.is_empty():
			continue
		if slot.locked:
			continue
		if slot.get_item_id() != item_id:
			continue

		var current_amount: int = slot.get_amount()
		remaining -= max(0, max_stack - current_amount)

	for slot in slots:
		if remaining <= 0:
			break
		if slot.is_empty():
			remaining -= max_stack

	return amount - max(0, remaining)


func get_free_slot_count() -> int:
	_ensure_slots()
	_ensure_starting_tool()
	var count: int = 0
	for slot in slots:
		if slot.is_empty():
			count += 1
	return count


func get_stack_size(_item_id: StringName) -> int:
	if _item_id == LEGACY_STARTING_TOOL_ID:
		return 1
	return DataRegistry.get_item_stack_size(_item_id, default_stack_size)


func is_empty() -> bool:
	for slot in slots:
		if not slot.is_empty():
			return false
	return true


func _ensure_slots() -> void:
	var target_slot_count: int = maxi(slot_count, 1)
	while slots.size() < target_slot_count:
		slots.append(InventorySlotModel.new())
	while slots.size() > target_slot_count:
		var last_slot = slots[slots.size() - 1]
		if not last_slot.is_empty():
			if _last_preserved_shrink_target != target_slot_count:
				push_warning("Inventory slot_count shrink to %d would delete occupied slots; preserving %d slots instead." % [target_slot_count, slots.size()])
				_last_preserved_shrink_target = target_slot_count
			return
		slots.pop_back()
	_last_preserved_shrink_target = -1


func _ensure_starting_tool() -> void:
	_ensure_slots()
	if slots.is_empty():
		return

	var first_slot = slots[0]
	var item_id: StringName = first_slot.get_item_id()
	if first_slot.is_empty() or item_id == STARTING_TOOL_ID or item_id == LEGACY_STARTING_TOOL_ID:
		first_slot.set_item(STARTING_TOOL_ID, 1, true, &"tool")


func _merge_into_existing_slots(item_id: StringName, amount: int, max_stack: int, start_index: int, end_index: int) -> int:
	var remaining: int = amount
	for i: int in range(start_index, end_index):
		if remaining <= 0:
			break

		var slot = slots[i]
		if slot.is_empty():
			continue
		if slot.locked:
			continue
		if slot.get_item_id() != item_id:
			continue

		var current_amount: int = slot.get_amount()
		if current_amount >= max_stack:
			continue

		var accepted: int = mini(remaining, max_stack - current_amount)
		slot.set_amount(current_amount + accepted)
		remaining -= accepted

	return remaining


func _fill_empty_slots(item_id: StringName, amount: int, max_stack: int, start_index: int, end_index: int) -> int:
	var remaining: int = amount
	for i: int in range(start_index, end_index):
		if remaining <= 0:
			break

		var slot = slots[i]
		if not slot.is_empty():
			continue

		var accepted: int = mini(remaining, max_stack)
		slot.set_item(item_id, accepted)
		remaining -= accepted

	return remaining
