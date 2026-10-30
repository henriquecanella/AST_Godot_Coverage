extends Area2D


func _physics_process(_delta):
	var bodies = get_overlapping_bodies()
	if bodies.size() > 0:
		for body in bodies:
			if body.is_on_floor():
				if has_node("Trackable"):
					$Trackable.mark_interacted()
				Singleton.get_node("Timer").running = false
