extends AnimatedSprite2D
 
func _ready():
	if has_node("Trackable"):
		$Trackable.setup_coverage()
	frame = randi() % 3
	if animation == "yellow": # Make caps rarer
		if frame == 2:
			if randi() % 5 != 0:
				frame = randi() % 2
