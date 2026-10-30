extends GPUParticles2D


func _ready():
	if has_node("Trackable"):
		$Trackable.setup_coverage()
	emitting = true


func _process(_delta):
	if !emitting:
		queue_free()
