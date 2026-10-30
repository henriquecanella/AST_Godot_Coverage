@tool
extends HBoxContainer

const _On : Texture2D = preload("res://sprites/ui/menu/tickbox_on.png")
const _Off : Texture2D = preload("res://sprites/ui/menu/tickbox_off.png")

@export var id : String

@export var title : String = "Tickbox" :
	set(value):
		$Label.text = value
		title = value

var skip_cursor : bool = false

var on : bool = true

func activate() -> void:
	on = !on
	$Box.texture = _On if on else _Off
	Settings.set_tickbox_setting(id, on)
	#SoundController.play_sound("ui_confirm")

func increase() -> void:
	pass

func decrease() -> void:
	pass

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	on = Settings.get_tickbox_setting(id)
	$Box.texture = _On if on else _Off
