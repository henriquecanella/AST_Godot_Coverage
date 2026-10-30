extends AnimatedSprite2D

func _ready():
	if has_node("Trackable"):
		$Trackable.setup_coverage()
	play()


func _on_SmokePoof_animation_finished():
	queue_free()
