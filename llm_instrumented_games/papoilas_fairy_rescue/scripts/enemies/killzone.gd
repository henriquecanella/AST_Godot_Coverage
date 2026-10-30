extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	if body.has_method("die"):
		if has_node("Trackable"):
			$Trackable.mark_interacted()
		body.die()
	Global.player_lifes -= 1
