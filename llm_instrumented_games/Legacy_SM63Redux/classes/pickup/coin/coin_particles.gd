extends GPUParticles2D


func _ready():
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	emitting = true


func _process(_delta):
	if !emitting:
		queue_free()
