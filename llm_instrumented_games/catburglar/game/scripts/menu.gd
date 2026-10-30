extends VBoxContainer

const _Arrow : Texture2D = preload("res://sprites/ui/menu/cursor.png")

var current_item : int = 0
var rebinding : bool = false
var rebinding_action : String
var target_cursor_y : float
var cursor_y : float
var active : bool = false
var time_to_next_analogue_input : float = 0.0

signal button_pressed
signal closed

func _on_button_pressed(button_id : String) -> void:
	if button_id == "back": # janky hack m8
		close()
	else:
		emit_signal("button_pressed", button_id)

func _on_rebinding_started(action_name : String) -> void:
	rebinding = true
	rebinding_action = action_name

func set_target_cursor_y() -> void:
	target_cursor_y = 0.0
	for i in range(0, current_item):
		if get_child(i) is Control:
			target_cursor_y += get_child(i).size.y

func maybe_skip(diff : int) -> void:
	if not (get_child(current_item) is Control) or get_child(current_item).skip_cursor:
		current_item = wrapi(current_item + diff, 0, get_child_count())
		maybe_skip(diff)

func close() -> void:
	current_item = 0
	maybe_skip(1)
	set_target_cursor_y()
	cursor_y = target_cursor_y
	emit_signal("closed")

func _draw() -> void:
	if not active: return
	draw_texture(_Arrow, Vector2(-30, cursor_y))

func _input_rebinding(event : InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		Settings.update_keybinding(rebinding_action, event.keycode)
		rebinding = false
		get_child(current_item).refresh()
	elif event is InputEventJoypadButton and event.is_pressed():
		if event.button_index in Settings.PERMITTED_BUTTONS:
			Settings.update_joybinding(rebinding_action, event.button_index)
		else:
			pass
		rebinding = false
		get_child(current_item).refresh()

func _input_menu(event : InputEvent) -> void:
	if event is InputEventJoypadMotion and time_to_next_analogue_input > 0.0:
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("up"):
		current_item = wrapi(current_item - 1, 0, get_child_count())
		maybe_skip(-1)
		get_viewport().set_input_as_handled()
		time_to_next_analogue_input = 0.2
		#SoundController.play_sound("ui_move")
	elif event.is_action_pressed("down"):
		current_item = wrapi(current_item + 1, 0, get_child_count())
		maybe_skip(1)
		get_viewport().set_input_as_handled()
		time_to_next_analogue_input = 0.2
		#SoundController.play_sound("ui_move")
	elif event.is_action_pressed("left"):
		get_child(current_item).decrease()
		get_viewport().set_input_as_handled()
		time_to_next_analogue_input = 0.2
	elif event.is_action_pressed("right"):
		get_child(current_item).increase()
		get_viewport().set_input_as_handled()
		time_to_next_analogue_input = 0.2
	elif event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		get_child(current_item).activate()
	elif event.is_action_pressed("shoot"):
		get_viewport().set_input_as_handled()
		close()
		#SoundController.play_sound("ui_menu_close")
	set_target_cursor_y()

func _input(event : InputEvent) -> void:
	if not active: return
	if rebinding:
		_input_rebinding(event)
	else:
		_input_menu(event)

func _physics_process(delta : float) -> void:
	if time_to_next_analogue_input > 0.0:
		time_to_next_analogue_input -= delta
	cursor_y = lerp(cursor_y, target_cursor_y, 20.0 * delta)
	queue_redraw()

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	maybe_skip(1)
	set_target_cursor_y()
	cursor_y = target_cursor_y
