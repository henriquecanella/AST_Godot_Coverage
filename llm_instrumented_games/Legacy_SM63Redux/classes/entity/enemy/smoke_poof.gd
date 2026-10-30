extends AnimatedSprite2D

func _ready():
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	play()


func _on_SmokePoof_animation_finished():
	queue_free()
