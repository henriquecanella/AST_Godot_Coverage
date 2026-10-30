extends Area2D

#@onready var game_manager = %GameManager
@onready var animation_player = $AnimationPlayer

func _on_body_entered(_body):
	$Trackable.mark_interacted()
	animation_player.play("pickup")
	Global.player_coins += 1
