extends Node2D

@onready var world: HearthlineWorld = $World as HearthlineWorld
@onready var player: PlayerController = $Player as PlayerController
@onready var hud: HearthlineHUD = $HUD as HearthlineHUD


func _ready() -> void:
	_ensure_input_actions()

	player.global_position = world.get_spawn_position()
	player.set_world(world)
	player.set_world_bounds(world.get_world_bounds())
	player.inventory_changed.connect(hud.set_inventory)
	player.inventory_slots_changed.connect(hud.set_inventory_slots)
	player.action_hint_changed.connect(hud.set_hint)
	player.station_opened.connect(hud.show_station)
	player.station_updated.connect(hud.update_station)
	player.station_closed.connect(hud.hide_station)
	world.time_of_day_changed.connect(hud.set_time_of_day)
	hud.build_requested.connect(player.start_building_placement)
	hud.station_input_requested.connect(player.load_station_recipe_inputs)
	hud.station_recipe_requested.connect(player.start_station_recipe)
	hud.station_output_collect_requested.connect(player.collect_active_station_outputs)
	hud.station_close_requested.connect(player.close_station_ui)
	hud.gameplay_input_block_changed.connect(player.set_gameplay_input_blocked)
	hud.pause_state_changed.connect(_on_pause_state_changed)

	hud.set_world_info(world.map_size, world.get_resource_count())
	hud.set_time_of_day(world.get_time_of_day_snapshot())
	hud.set_inventory(player.get_inventory_snapshot())
	hud.set_inventory_slots(player.get_inventory_slots_snapshot())
	hud.set_hint("WASD - move | Mouse - aim | LMB/E - lock cutter | LMB - build | Walk over drops to pick up")


func _on_pause_state_changed(paused: bool) -> void:
	get_tree().paused = paused
	player.set_gameplay_mode(PlayerController.MODE_PAUSE if paused else PlayerController.MODE_NORMAL)


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
	_ensure_key_action(&"inventory", KEY_I)


func _ensure_key_action(action: StringName, keycode: int) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)

	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == keycode:
			return
		if event is InputEventMouseButton and event.button_index == keycode:
			return

	if keycode >= MOUSE_BUTTON_LEFT and keycode <= MOUSE_BUTTON_XBUTTON2:
		var mouse_event: InputEventMouseButton = InputEventMouseButton.new()
		mouse_event.button_index = keycode
		InputMap.action_add_event(action, mouse_event)
	else:
		var key_event: InputEventKey = InputEventKey.new()
		key_event.physical_keycode = keycode
		InputMap.action_add_event(action, key_event)
