extends Camera2D

signal bottom

func _process(delta):
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	var screenBottom = get_screen_center_position().y + get_viewport_rect().size.y / 2
	limit_bottom = screenBottom
	bottom.emit(screenBottom)
