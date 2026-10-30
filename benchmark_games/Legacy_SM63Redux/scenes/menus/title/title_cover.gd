extends ColorRect


func _init():
	if has_node("Trackable"):
		$Trackable.setup_coverage()
	visible = true


func _process(delta):
	modulate.a -= delta
	if modulate.a <= 0:
		queue_free()
