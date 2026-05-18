extends Node2D

@onready var world: Node2D = $World
@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD


func _ready() -> void:
	_ensure_input_actions()

	player.global_position = world.get_spawn_position()
	player.set_world_bounds(world.get_world_bounds())
	player.inventory_changed.connect(hud.set_inventory)
	player.action_hint_changed.connect(hud.set_hint)

	hud.set_world_info(world.map_size, world.get_resource_count())
	hud.set_inventory(player.get_inventory_snapshot())
	hud.set_hint("WASD - move | LMB/E - mine with pickaxe | Tab - inventory hint")


func _ensure_input_actions() -> void:
	_ensure_key_action(&"move_up", KEY_W)
	_ensure_key_action(&"move_up", KEY_UP)
	_ensure_key_action(&"move_down", KEY_S)
	_ensure_key_action(&"move_down", KEY_DOWN)
	_ensure_key_action(&"move_left", KEY_A)
	_ensure_key_action(&"move_left", KEY_LEFT)
	_ensure_key_action(&"move_right", KEY_D)
	_ensure_key_action(&"move_right", KEY_RIGHT)
	_ensure_key_action(&"interact", KEY_E)
	_ensure_key_action(&"attack", MOUSE_BUTTON_LEFT)
	_ensure_key_action(&"inventory", KEY_TAB)


func _ensure_key_action(action: StringName, keycode: int) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)

	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == keycode:
			return
		if event is InputEventMouseButton and event.button_index == keycode:
			return

	if keycode >= MOUSE_BUTTON_LEFT and keycode <= MOUSE_BUTTON_XBUTTON2:
		var mouse_event := InputEventMouseButton.new()
		mouse_event.button_index = keycode
		InputMap.action_add_event(action, mouse_event)
	else:
		var key_event := InputEventKey.new()
		key_event.physical_keycode = keycode
		InputMap.action_add_event(action, key_event)

