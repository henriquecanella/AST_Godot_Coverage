extends PointLight2D

@onready var area_light_player : Area2D = $Area2D_LightPlayer

func is_lighting_player() -> bool:
	for body in area_light_player.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false


func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()