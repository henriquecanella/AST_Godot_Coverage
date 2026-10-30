@tool
extends HBoxContainer

const ICON_WIDTH : int = 64

@export var title : String = "Action Name" :
	set(value):
		if has_node("Label"):
			$Label.text = value
			title = value

@export var action_name : String

@onready var key : Label = $Key
@onready var button : TextureRect = $Button

var skip_cursor : bool = false

func refresh() -> void:
	var keycode : int = Settings.get_keybinding(action_name)
	var keyname : String = OS.get_keycode_string(keycode)
	$Key.text = "[" + keyname + "] / "
	var joycode : int = Settings.get_joybinding(action_name)
	var joy_offset : int = Settings.JOY_BUTTON_ICON[joycode]
	$Button.texture.region.position.x = joy_offset * ICON_WIDTH
	$Button.texture.region.position.y = Settings.controller_type * ICON_WIDTH
	$Button.show()

func activate() -> void:
	get_parent()._on_rebinding_started(action_name)
	key.text = "..."
	button.hide()
	#SoundController.play_sound("ui_confirm")

func increase() -> void:
	pass

func decrease() -> void:
	pass

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	button.texture = button.texture.duplicate(true)
	refresh()
