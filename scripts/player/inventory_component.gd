extends Node
class_name InventoryComponent

signal changed(items: Dictionary)

@export var slot_count: int = 16
@export var default_stack_size: int = 99

var slots: Array[Dictionary] = []


func _ready() -> void:
	_ensure_slots()


func add_item(item_id: StringName, amount: int) -> int:
	var leftover: int = add_item_with_leftover(item_id, amount)
	return amount - leftover


func add_item_with_leftover(item_id: StringName, amount: int) -> int:
	if amount <= 0:
		return 0

	_ensure_slots()

	var remaining: int = amount
	var max_stack: int = get_stack_size(item_id)

	for i: int in range(slots.size()):
		if remaining <= 0:
			break

		var slot: Dictionary = slots[i]
		if slot.is_empty():
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

	for i: int in range(slots.size()):
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

	changed.emit(get_items())
	return remaining


func remove_item(item_id: StringName, amount: int) -> int:
	if amount <= 0:
		return 0

	_ensure_slots()

	var remaining: int = amount
	var removed: int = 0

	for i: int in range(slots.size()):
		if remaining <= 0:
			break

		var slot: Dictionary = slots[i]
		if slot.is_empty():
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
	var remaining: int = amount
	var max_stack: int = get_stack_size(item_id)

	for slot: Dictionary in slots:
		if remaining <= 0:
			break
		if slot.is_empty():
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
	var count: int = 0
	for slot: Dictionary in slots:
		if slot.is_empty():
			count += 1
	return count


func get_stack_size(_item_id: StringName) -> int:
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
