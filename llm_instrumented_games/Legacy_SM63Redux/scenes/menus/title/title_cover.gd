extends ColorRect


func _init():
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	visible = true


func _process(delta):
	modulate.a -= delta
	if modulate.a <= 0:
		queue_free()
