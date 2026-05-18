extends CanvasLayer
class_name HearthlineHUD

var _inventory_label: Label
var _hint_label: Label
var _world_label: Label


func _ready() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_LEFT)
	margin.offset_left = 12.0
	margin.offset_top = 12.0
	margin.offset_right = 360.0
	margin.offset_bottom = 230.0
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


func set_hint(text: String) -> void:
	if _hint_label == null:
		return
	_hint_label.text = text
