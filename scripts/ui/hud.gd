extends CanvasLayer
class_name HearthlineHUD

signal build_requested(building_id: StringName)

const TOOLBELT_SLOT_COUNT: int = 9

var _inventory_label: Label
var _hint_label: Label
var _world_label: Label
var _toolbelt_grid: GridContainer
var _inventory_window: PanelContainer
var _inventory_grid: GridContainer
var _inventory_content: VBoxContainer
var _building_content: VBoxContainer
var _upgrades_content: VBoxContainer
var _main_menu_content: VBoxContainer
var _toolbelt_labels: Array[Label] = []
var _inventory_labels: Array[Label] = []


func _ready() -> void:
	_build_status_panel()
	_build_toolbelt()
	_build_inventory_window()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory_window()
		get_viewport().set_input_as_handled()


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
	_update_toolbelt(slots)
	_update_inventory_window(slots)
	_update_inventory_capacity(slots)


func set_hint(text: String) -> void:
	if _hint_label == null:
		return
	_hint_label.text = text


func toggle_inventory_window() -> void:
	if _inventory_window == null:
		return

	_inventory_window.visible = not _inventory_window.visible
	if _inventory_window.visible:
		_select_category(&"inventory")


func _build_status_panel() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.anchor_left = 0.0
	margin.anchor_top = 0.0
	margin.anchor_right = 0.0
	margin.anchor_bottom = 0.0
	margin.offset_left = 12.0
	margin.offset_top = 12.0
	margin.offset_right = 390.0
	margin.offset_bottom = 160.0
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

	_hint_label = Label.new()
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.text = ""
	box.add_child(_hint_label)


func _build_toolbelt() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.anchor_left = 0.5
	margin.anchor_top = 1.0
	margin.anchor_right = 0.5
	margin.anchor_bottom = 1.0
	margin.offset_left = -475.0
	margin.offset_top = -92.0
	margin.offset_right = 475.0
	margin.offset_bottom = -16.0
	add_child(margin)

	var panel: PanelContainer = PanelContainer.new()
	margin.add_child(panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)

	var title: Label = Label.new()
	title.text = "Toolbelt"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	_toolbelt_grid = GridContainer.new()
	_toolbelt_grid.columns = TOOLBELT_SLOT_COUNT
	box.add_child(_toolbelt_grid)


func _build_inventory_window() -> void:
	_inventory_window = PanelContainer.new()
	_inventory_window.visible = false
	_inventory_window.anchor_left = 0.5
	_inventory_window.anchor_top = 0.5
	_inventory_window.anchor_right = 0.5
	_inventory_window.anchor_bottom = 0.5
	_inventory_window.offset_left = -620.0
	_inventory_window.offset_top = -290.0
	_inventory_window.offset_right = 620.0
	_inventory_window.offset_bottom = 290.0
	add_child(_inventory_window)

	var root_margin: MarginContainer = MarginContainer.new()
	root_margin.add_theme_constant_override("margin_left", 12)
	root_margin.add_theme_constant_override("margin_top", 12)
	root_margin.add_theme_constant_override("margin_right", 12)
	root_margin.add_theme_constant_override("margin_bottom", 12)
	_inventory_window.add_child(root_margin)

	var root: HBoxContainer = HBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	root_margin.add_child(root)

	var equipment_frame: PanelContainer = PanelContainer.new()
	equipment_frame.custom_minimum_size = Vector2(180.0, 520.0)
	root.add_child(equipment_frame)
	_build_equipment_panel(equipment_frame)

	var content_frame: PanelContainer = PanelContainer.new()
	content_frame.custom_minimum_size = Vector2(820.0, 520.0)
	root.add_child(content_frame)

	var content_margin: MarginContainer = MarginContainer.new()
	content_margin.add_theme_constant_override("margin_left", 10)
	content_margin.add_theme_constant_override("margin_top", 10)
	content_margin.add_theme_constant_override("margin_right", 10)
	content_margin.add_theme_constant_override("margin_bottom", 10)
	content_frame.add_child(content_margin)

	var content_stack: VBoxContainer = VBoxContainer.new()
	content_margin.add_child(content_stack)

	_inventory_content = _build_inventory_content()
	_building_content = _build_building_content()
	_upgrades_content = _build_placeholder_content("Upgrades", "Upgrade systems are not available yet.")
	_main_menu_content = _build_placeholder_content("Main Menu", "Main menu actions are not available yet.")

	content_stack.add_child(_inventory_content)
	content_stack.add_child(_building_content)
	content_stack.add_child(_upgrades_content)
	content_stack.add_child(_main_menu_content)

	var category_box: VBoxContainer = VBoxContainer.new()
	category_box.custom_minimum_size = Vector2(180.0, 520.0)
	category_box.add_theme_constant_override("separation", 8)
	root.add_child(category_box)

	_add_category_button(category_box, "Inventory", &"inventory")
	_add_category_button(category_box, "Building", &"building")
	_add_category_button(category_box, "Upgrades", &"upgrades")
	_add_category_button(category_box, "Main Menu", &"main_menu")
	_select_category(&"inventory")


func _build_inventory_content() -> VBoxContainer:
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)

	var title: Label = Label.new()
	title.text = "Inventory"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var help: Label = Label.new()
	help.text = "Top row is the toolbelt. Press Tab or I to close."
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(help)

	_inventory_grid = GridContainer.new()
	_inventory_grid.columns = TOOLBELT_SLOT_COUNT
	box.add_child(_inventory_grid)
	return box


func _build_building_content() -> VBoxContainer:
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)

	var title: Label = Label.new()
	title.text = "Building"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var help: Label = Label.new()
	help.text = "Choose a building, then place it near the player."
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(help)

	var building_grid: GridContainer = GridContainer.new()
	building_grid.columns = 3
	box.add_child(building_grid)

	_add_building_slot(building_grid, &"furnace", "Furnace", "Cost: 2 stone, 1 wood\nSize: 2x2")
	_add_building_slot(building_grid, &"forge", "Forge", "Cost: 4 stone, 2 ore\nSize: 2x2")
	_add_building_slot(building_grid, &"workbench", "Workbench", "Cost: 2 wood, 1 stone\nSize: 2x2")
	return box


func _build_equipment_panel(parent: PanelContainer) -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	parent.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	var title: Label = Label.new()
	title.text = "Character"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	_add_equipment_slot(box, "Helmet")
	_add_equipment_slot(box, "Armor")
	_add_equipment_slot(box, "Gloves")
	_add_equipment_slot(box, "Boots")
	_add_equipment_slot(box, "Belt")
	_add_equipment_slot(box, "Amulet")


func _add_equipment_slot(parent: VBoxContainer, slot_name: String) -> void:
	var label: Label = Label.new()
	label.custom_minimum_size = Vector2(150.0, 42.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = "%s\nEmpty" % slot_name
	label.modulate = Color(0.82, 0.86, 0.90)
	parent.add_child(label)


func _add_building_slot(parent: GridContainer, building_id: StringName, title: String, details: String) -> void:
	var slot: VBoxContainer = VBoxContainer.new()
	slot.custom_minimum_size = Vector2(240.0, 150.0)
	slot.add_theme_constant_override("separation", 6)
	parent.add_child(slot)

	var name_label: Label = Label.new()
	name_label.text = title
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot.add_child(name_label)

	var details_label: Label = Label.new()
	details_label.text = details
	details_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	slot.add_child(details_label)

	var button: Button = Button.new()
	button.text = "Create"
	button.pressed.connect(Callable(self, "_request_building").bind(building_id))
	slot.add_child(button)


func _request_building(building_id: StringName) -> void:
	build_requested.emit(building_id)
	if _inventory_window != null:
		_inventory_window.visible = false


func _build_placeholder_content(title_text: String, body_text: String) -> VBoxContainer:
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)

	var title: Label = Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var body: Label = Label.new()
	body.text = body_text
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body)
	return box


func _add_category_button(parent: VBoxContainer, text: String, category_id: StringName) -> void:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(160.0, 46.0)
	button.pressed.connect(Callable(self, "_select_category").bind(category_id))
	parent.add_child(button)


func _select_category(category_id: StringName) -> void:
	if _inventory_content != null:
		_inventory_content.visible = category_id == &"inventory"
	if _building_content != null:
		_building_content.visible = category_id == &"building"
	if _upgrades_content != null:
		_upgrades_content.visible = category_id == &"upgrades"
	if _main_menu_content != null:
		_main_menu_content.visible = category_id == &"main_menu"


func _update_toolbelt(slots: Array) -> void:
	if _toolbelt_grid == null:
		return

	var count: int = mini(TOOLBELT_SLOT_COUNT, slots.size())
	_ensure_labels(_toolbelt_grid, _toolbelt_labels, count, Vector2(96.0, 44.0))

	for i: int in range(count):
		var slot: Dictionary = slots[i]
		var label: Label = _toolbelt_labels[i]
		label.text = _format_slot_text(i, slot, true)
		label.modulate = _get_slot_modulate(slot)


func _update_inventory_window(slots: Array) -> void:
	if _inventory_grid == null:
		return

	_ensure_labels(_inventory_grid, _inventory_labels, slots.size(), Vector2(78.0, 48.0))

	for i: int in range(slots.size()):
		var slot: Dictionary = slots[i]
		var label: Label = _inventory_labels[i]
		label.text = _format_slot_text(i, slot, false)
		label.modulate = _get_slot_modulate(slot)


func _update_inventory_capacity(slots: Array) -> void:
	if _inventory_label == null:
		return

	var used_slots: int = 0
	for slot: Dictionary in slots:
		if not slot.is_empty():
			used_slots += 1

	_inventory_label.text = "Inventory: %d/%d slots used" % [used_slots, slots.size()]


func _format_slot_text(index: int, slot: Dictionary, compact: bool) -> String:
	var slot_number: int = index + 1
	if slot.is_empty():
		if compact:
			return "%d\nEmpty" % slot_number
		return "%02d\nEmpty" % slot_number

	var item_id: StringName = StringName(slot.get("item_id", &""))
	var amount: int = int(slot.get("amount", 0))
	var locked: bool = bool(slot.get("locked", false))

	if locked and item_id == &"pickaxe":
		if compact:
			return "%d\nPickaxe" % slot_number
		return "%02d\nPickaxe" % slot_number

	if compact:
		return "%d\n%s x%d" % [slot_number, String(item_id), amount]
	return "%02d\n%s x%d" % [slot_number, String(item_id), amount]


func _get_slot_modulate(slot: Dictionary) -> Color:
	if slot.is_empty():
		return Color(0.72, 0.75, 0.76)
	if bool(slot.get("locked", false)):
		return Color(1.0, 0.94, 0.62)
	return Color.WHITE


func _ensure_labels(parent: GridContainer, labels: Array[Label], count: int, size: Vector2) -> void:
	while labels.size() < count:
		var label: Label = Label.new()
		label.custom_minimum_size = size
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		parent.add_child(label)
		labels.append(label)

	while labels.size() > count:
		var label: Label = labels.pop_back()
		label.queue_free()
