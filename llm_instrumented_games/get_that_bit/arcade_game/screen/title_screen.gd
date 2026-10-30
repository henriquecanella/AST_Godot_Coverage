extends Control

var Game

@onready var button_start: TextureButton = $ButtonStart


func _ready():
	Game = get_parent()
	button_start.grab_focus()


func _process(_delta):
	if Input.is_action_just_pressed("jump1"):
		_start_game()


func _on_button_start_pressed():
	_start_game()


func _start_game():
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	Game.start()
