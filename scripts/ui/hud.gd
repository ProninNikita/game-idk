extends CanvasLayer
class_name HearthlineHUD

var _inventory_label: Label
var _hint_label: Label
var _world_label: Label
var _slot_grid: GridContainer
var _slot_labels: Array[Label] = []


func _ready() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_LEFT)
	margin.offset_left = 12.0
	margin.offset_top = 12.0
	margin.offset_right = 430.0
	margin.offset_bottom = 360.0
	add_child(margin)

	var panel: PanelContainer = PanelContainer.new()
	margin.add_child(panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	var title: Label = Label.new()
	title.text = "Project Hearthline Prototype"
	box.add_child(title)

	_world_label = Label.new()
	_world_label.text = "World: loading"
	box.add_child(_world_label)

	_inventory_label = Label.new()
	_inventory_label.text = "Inventory: empty"
	box.add_child(_inventory_label)

	var inventory_title: Label = Label.new()
	inventory_title.text = "Inventory Slots"
	box.add_child(inventory_title)

	_slot_grid = GridContainer.new()
	_slot_grid.columns = 4
	box.add_child(_slot_grid)

	_hint_label = Label.new()
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.text = ""
	box.add_child(_hint_label)


func set_world_info(map_size: Vector2i, resource_count: int) -> void:
	if _world_label == null:
		return
	_world_label.text = "Map: %dx%d | Resources: %d" % [map_size.x, map_size.y, resource_count]


func set_inventory(items: Dictionary) -> void:
	if _inventory_label == null:
		return

	if items.is_empty():
		_inventory_label.text = "Inventory: empty"
		return

	var keys: Array = items.keys()
	keys.sort()

	var parts: Array[String] = []
	for key: Variant in keys:
		parts.append("%s: %d" % [String(key), int(items[key])])

	_inventory_label.text = "Inventory: " + ", ".join(parts)


func set_inventory_slots(slots: Array) -> void:
	if _slot_grid == null:
		return

	_ensure_slot_labels(slots.size())

	var used_slots: int = 0
	for i: int in range(slots.size()):
		var slot: Dictionary = slots[i]
		var label: Label = _slot_labels[i]
		if slot.is_empty():
			label.text = "%02d\nEmpty" % [i + 1]
			label.modulate = Color(0.72, 0.75, 0.76)
			continue

		used_slots += 1
		var item_id: StringName = StringName(slot.get("item_id", &""))
		var amount: int = int(slot.get("amount", 0))
		label.text = "%02d\n%s x%d" % [i + 1, String(item_id), amount]
		label.modulate = Color.WHITE

	if _inventory_label != null:
		_inventory_label.text = "Inventory: %d/%d slots used" % [used_slots, slots.size()]


func set_hint(text: String) -> void:
	if _hint_label == null:
		return
	_hint_label.text = text


func _ensure_slot_labels(count: int) -> void:
	while _slot_labels.size() < count:
		var label: Label = Label.new()
		label.custom_minimum_size = Vector2(92.0, 42.0)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_slot_grid.add_child(label)
		_slot_labels.append(label)

	while _slot_labels.size() > count:
		var label: Label = _slot_labels.pop_back()
		label.queue_free()
