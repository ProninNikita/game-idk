extends Node
class_name InventoryComponent

signal changed(items: Dictionary)

const STARTING_TOOL_ID: StringName = &"pickaxe"

@export var slot_count: int = 27
@export var toolbelt_slot_count: int = 9
@export var default_stack_size: int = 99

var slots: Array[Dictionary] = []


func _ready() -> void:
	_ensure_slots()
	_ensure_starting_pickaxe()


func add_item(item_id: StringName, amount: int) -> int:
	var leftover: int = add_item_with_leftover(item_id, amount)
	return amount - leftover


func add_item_with_leftover(item_id: StringName, amount: int) -> int:
	if amount <= 0:
		return 0

	_ensure_slots()
	_ensure_starting_pickaxe()

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

	_ensure_slots()
	_ensure_starting_pickaxe()

	var remaining: int = amount
	var removed: int = 0

	for i: int in range(slots.size()):
		if remaining <= 0:
			break

		var slot: Dictionary = slots[i]
		if slot.is_empty():
			continue
		if bool(slot.get("locked", false)):
			continue
		if StringName(slot.get("item_id", &"")) != item_id:
			continue

		var slot_amount: int = int(slot.get("amount", 0))
		var take: int = mini(remaining, slot_amount)
		slot_amount -= take
		remaining -= take
		removed += take

		if slot_amount <= 0:
			slots[i] = {}
		else:
			slot["amount"] = slot_amount
			slots[i] = slot

	changed.emit(get_items())
	return removed


func get_count(item_id: StringName) -> int:
	var total: int = 0
	for slot: Dictionary in slots:
		if slot.is_empty():
			continue
		if StringName(slot.get("item_id", &"")) == item_id:
			total += int(slot.get("amount", 0))
	return total


func get_items() -> Dictionary:
	var summary: Dictionary = {}
	for slot: Dictionary in slots:
		if slot.is_empty():
			continue
		var item_id: StringName = StringName(slot.get("item_id", &""))
		if item_id == &"":
			continue
		summary[item_id] = int(summary.get(item_id, 0)) + int(slot.get("amount", 0))
	return summary


func get_slots() -> Array[Dictionary]:
	_ensure_slots()
	_ensure_starting_pickaxe()
	var copy: Array[Dictionary] = []
	for slot: Dictionary in slots:
		copy.append(slot.duplicate())
	return copy


func can_accept_item(item_id: StringName, amount: int = 1) -> bool:
	return get_acceptable_amount(item_id, amount) > 0


func get_acceptable_amount(item_id: StringName, amount: int) -> int:
	if amount <= 0:
		return 0

	_ensure_slots()
	_ensure_starting_pickaxe()
	var remaining: int = amount
	var max_stack: int = get_stack_size(item_id)

	for slot: Dictionary in slots:
		if remaining <= 0:
			break
		if slot.is_empty():
			continue
		if bool(slot.get("locked", false)):
			continue
		if StringName(slot.get("item_id", &"")) != item_id:
			continue

		var current_amount: int = int(slot.get("amount", 0))
		remaining -= max(0, max_stack - current_amount)

	for slot: Dictionary in slots:
		if remaining <= 0:
			break
		if slot.is_empty():
			remaining -= max_stack

	return amount - max(0, remaining)


func get_free_slot_count() -> int:
	_ensure_slots()
	_ensure_starting_pickaxe()
	var count: int = 0
	for slot: Dictionary in slots:
		if slot.is_empty():
			count += 1
	return count


func get_stack_size(_item_id: StringName) -> int:
	if _item_id == STARTING_TOOL_ID:
		return 1
	return default_stack_size


func is_empty() -> bool:
	for slot: Dictionary in slots:
		if not slot.is_empty():
			return false
	return true


func _ensure_slots() -> void:
	while slots.size() < slot_count:
		slots.append({})
	while slots.size() > slot_count:
		slots.pop_back()


func _ensure_starting_pickaxe() -> void:
	_ensure_slots()
	if slots.is_empty():
		return

	var first_slot: Dictionary = slots[0]
	if first_slot.is_empty():
		slots[0] = {
			"item_id": STARTING_TOOL_ID,
			"amount": 1,
			"locked": true,
			"slot_type": &"tool",
		}
		return

	if StringName(first_slot.get("item_id", &"")) == STARTING_TOOL_ID:
		first_slot["amount"] = 1
		first_slot["locked"] = true
		first_slot["slot_type"] = &"tool"
		slots[0] = first_slot


func _merge_into_existing_slots(item_id: StringName, amount: int, max_stack: int, start_index: int, end_index: int) -> int:
	var remaining: int = amount
	for i: int in range(start_index, end_index):
		if remaining <= 0:
			break

		var slot: Dictionary = slots[i]
		if slot.is_empty():
			continue
		if bool(slot.get("locked", false)):
			continue
		if StringName(slot.get("item_id", &"")) != item_id:
			continue

		var current_amount: int = int(slot.get("amount", 0))
		if current_amount >= max_stack:
			continue

		var accepted: int = mini(remaining, max_stack - current_amount)
		slot["amount"] = current_amount + accepted
		slots[i] = slot
		remaining -= accepted

	return remaining


func _fill_empty_slots(item_id: StringName, amount: int, max_stack: int, start_index: int, end_index: int) -> int:
	var remaining: int = amount
	for i: int in range(start_index, end_index):
		if remaining <= 0:
			break

		var slot: Dictionary = slots[i]
		if not slot.is_empty():
			continue

		var accepted: int = mini(remaining, max_stack)
		slots[i] = {
			"item_id": item_id,
			"amount": accepted,
		}
		remaining -= accepted

	return remaining
