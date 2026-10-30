extends TextureRect

@onready var camera: Camera2D = $"/root/Main/Camera"


func _process(_dt):
	material.set_shader_parameter("camera_position", camera.position)

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()
