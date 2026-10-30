extends Area2D

@export_node_path("Light2D") var path_light
@onready var light : Light2D = get_node(path_light)
@onready var audio_switch : AudioStreamPlayer2D = $Audio_Switch

func interact() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	light.enabled = !light.enabled
	audio_switch.play()
