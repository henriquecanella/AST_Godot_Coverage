@tool
extends HBoxContainer

@export var id : String

@export var title : String = "Button" :
	set(value):
		$Label.text = value
		title = value

var skip_cursor : bool = false

func activate() -> void:
	get_parent()._on_button_pressed(id)
	#SoundController.play_sound("ui_menu_close" if id == "back" else "ui_confirm")

func increase() -> void:
	pass

func decrease() -> void:
	pass


func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()