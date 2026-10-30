extends Control

var Game

func _ready() -> void:
	Game = get_parent()

func _process(_delta):
	if Input.is_action_just_pressed("jump1")\
	or Input.is_action_just_pressed("ui_accept"):
		_restart_game()


func _on_timer_restart_timeout():
	_restart_game()


func _restart_game():
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	Game.reset_game()
