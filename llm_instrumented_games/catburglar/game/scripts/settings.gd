extends Node

enum ControllerType {XBOX, NINTENDO, PLAYSTATION}

const CONFIG_PATH : String = "user://settings.ini"

const ACTIONS : Array = ["up", "down", "left", "right", "interact", "shoot", "pause"]
const PERMITTED_BUTTONS : Array = [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_X, JOY_BUTTON_Y, JOY_BUTTON_BACK, JOY_BUTTON_START, JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT]
const DEFAULT_KEYBINDINGS : Dictionary = {
	"up": KEY_UP, "down": KEY_DOWN, "left": KEY_LEFT, "right": KEY_RIGHT, "interact": KEY_X, "shoot": KEY_C, "pause": KEY_ENTER
}
const DEFAULT_JOYBINDINGS : Dictionary = {
	"up": JOY_BUTTON_DPAD_UP, "down": JOY_BUTTON_DPAD_DOWN, "left": JOY_BUTTON_DPAD_LEFT, "right": JOY_BUTTON_DPAD_RIGHT, "interact": JOY_BUTTON_A, "shoot": JOY_BUTTON_X, "pause": JOY_BUTTON_START
}
const JOY_BUTTON_ICON : Dictionary = {
	JOY_BUTTON_A: 0, JOY_BUTTON_B: 1, JOY_BUTTON_X: 2, JOY_BUTTON_Y: 3, JOY_BUTTON_BACK: 4, JOY_BUTTON_START: 5, JOY_BUTTON_LEFT_SHOULDER: 6, JOY_BUTTON_RIGHT_SHOULDER: 7, JOY_BUTTON_DPAD_LEFT: 8, JOY_BUTTON_DPAD_RIGHT: 9, JOY_BUTTON_DPAD_UP: 10, JOY_BUTTON_DPAD_DOWN: 11
}

var fullscreen : bool = false
var show_mouse_cursor : bool = true

var sfx_volume : int = 10
var bgm_volume : int = 10
var ui_volume : int = 10
var amb_volume : int = 10
var vo_volume : int = 10

var vibration : bool = true

var keybindings : Dictionary
var joybindings : Dictionary
var controller_type : int = ControllerType.XBOX

var last_input_was_controller : bool = false

var config_file : ConfigFile

func apply_tickbox_settings() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE if show_mouse_cursor else DisplayServer.MOUSE_MODE_HIDDEN)

func apply_volume_setting(bus_name : String, amount : int) -> void:
	var bus_id : int = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_id, linear_to_db(amount / 12.0))

func apply_selector_settings() -> void:
	get_tree().call_group("keybind_or_prompt", "refresh")

func apply_volume_settings() -> void:
	apply_volume_setting("sfx", sfx_volume)
	apply_volume_setting("bgm", bgm_volume)
	apply_volume_setting("ui", ui_volume)
	apply_volume_setting("amb", amb_volume)
	apply_volume_setting("vo", vo_volume)

func get_tickbox_setting(setting_name : String) -> bool:
	match setting_name:
		"fullscreen": return fullscreen
		"show_mouse_cursor": return show_mouse_cursor
		"vibration": return vibration
		_:
			printerr("Unknown setting: " + setting_name)
			return false

func set_tickbox_setting(setting_name : String, value : bool) -> void:
	if setting_name == "vibration" and value:
		Input.start_joy_vibration(0, 1.0, 1.0, 0.25)
	match setting_name:
		"fullscreen": fullscreen = value
		"show_mouse_cursor": show_mouse_cursor = value
		"vibration": vibration = value
		_: printerr("Unknown setting: " + setting_name)
	apply_tickbox_settings()
	save_settings()

func get_selector_setting(setting_name : String) -> int:
	match setting_name:
		"controller_type": return controller_type
		_:
			printerr("Unknown setting: " + setting_name)
			return 0

func set_selector_setting(setting_name : String, value : int) -> void:
	match setting_name:
		"controller_type": controller_type = value
	apply_selector_settings()
	save_settings()

func get_volume_setting(setting_name : String) -> int:
	match setting_name:
		"sfx": return sfx_volume
		"bgm": return bgm_volume
		"ui": return ui_volume
		"amb": return amb_volume
		"vo": return vo_volume
		_:
			printerr("Unknown setting: " + setting_name)
			return 0

func set_volume_setting(setting_name : String, value : int) -> void:
	match setting_name:
		"sfx": sfx_volume = value
		"bgm": bgm_volume = value
		"ui": ui_volume = value
		"amb": amb_volume = value
		"vo": vo_volume = value
		_: printerr("Unknown setting: " + setting_name)
	apply_volume_settings()
	save_settings()

func get_keybinding(action_name : String) -> int:
	if keybindings.has(action_name):
		return keybindings[action_name]
	return DEFAULT_KEYBINDINGS[action_name]

func get_joybinding(action_name : String) -> int:
	if joybindings.has(action_name):
		return joybindings[action_name]
	return DEFAULT_JOYBINDINGS[action_name]

func update_keybinding(action_name : String, key_id : int) -> void:
	for other_action in ACTIONS:
		if get_keybinding(other_action) == key_id:
			keybindings[other_action] = get_keybinding(action_name)
	keybindings[action_name] = key_id
	update_actions()
	save_settings()
	get_tree().call_group("keybind_or_prompt", "refresh")

func update_joybinding(action_name : String, button_id : int) -> void:
	for other_action in ACTIONS:
		if get_joybinding(other_action) == button_id:
			joybindings[other_action] = get_joybinding(action_name)
	joybindings[action_name] = button_id
	update_actions()
	save_settings()
	get_tree().call_group("keybind_or_prompt", "refresh")

func update_actions() -> void:
	for action in ACTIONS:
		InputMap.action_erase_events(action)
		# Add joypad event
		var joy_event : InputEvent = InputEventJoypadButton.new()
		joy_event.button_index = get_joybinding(action)
		InputMap.action_add_event(action, joy_event)
		# Add key event
		var key_event : InputEvent = InputEventKey.new()
		key_event.keycode = get_keybinding(action)
		InputMap.action_add_event(action, key_event)
		# Add analogue stick event, maybe
		if get_joybinding(action) in [JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT]:
			var axis_event : InputEvent = InputEventJoypadMotion.new()
			axis_event.axis = JOY_AXIS_LEFT_X if get_joybinding(action) in [JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT] else JOY_AXIS_LEFT_Y
			axis_event.axis_value = 0.5 if get_joybinding(action) in [JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_DOWN] else -0.5
			InputMap.action_add_event(action, axis_event)

func load_settings() -> void:
	config_file.load(CONFIG_PATH)
	fullscreen = config_file.get_value("graphics", "fullscreen", false)
	show_mouse_cursor = config_file.get_value("graphics", "show_mouse_cursor", true)
	sfx_volume = config_file.get_value("audio", "sfx", 10)
	bgm_volume = config_file.get_value("audio", "bgm", 10)
	ui_volume = config_file.get_value("audio", "ui", 10)
	amb_volume = config_file.get_value("audio", "amb", 10)
	vo_volume = config_file.get_value("audio", "vo", 10)
	controller_type = config_file.get_value("game", "controller_type", ControllerType.XBOX)
	for action_name in ACTIONS:
		keybindings[action_name] = config_file.get_value("keybindings", action_name, DEFAULT_KEYBINDINGS[action_name])
		joybindings[action_name] = config_file.get_value("joybindings", action_name, DEFAULT_JOYBINDINGS[action_name])

func save_settings() -> void:
	config_file.set_value("graphics", "fullscreen", fullscreen)
	config_file.set_value("graphics", "show_mouse_cursor", show_mouse_cursor)
	config_file.set_value("audio", "sfx", sfx_volume)
	config_file.set_value("audio", "bgm", bgm_volume)
	config_file.set_value("audio", "ui", ui_volume)
	config_file.set_value("audio", "amb", amb_volume)
	config_file.set_value("audio", "vo", vo_volume)
	config_file.set_value("game", "controller_type", controller_type)
	for action_name in ACTIONS:
		config_file.set_value("keybindings", action_name, get_keybinding(action_name))
		config_file.set_value("joybindings", action_name, get_joybinding(action_name))
	config_file.save(CONFIG_PATH)

func _input(event : InputEvent) -> void:
	if event is InputEventJoypadButton and event.is_pressed():
		if !last_input_was_controller:
			last_input_was_controller = true
			get_tree().call_group("keybind_or_prompt", "refresh")
	elif event is InputEventKey and event.is_pressed():
		if last_input_was_controller:
			last_input_was_controller = false
			get_tree().call_group("keybind_or_prompt", "refresh")

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	config_file = ConfigFile.new()
	load_settings()
	apply_tickbox_settings()
	apply_selector_settings()
	apply_volume_settings()
	update_actions()
