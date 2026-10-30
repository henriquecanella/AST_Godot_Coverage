extends PointLight2D

@export var light_range : float

@onready var raycast : RayCast2D = $RayCast2D
@onready var area : Area2D = $Area2D

func is_player_in_area() -> bool:
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false

func is_raycast_on_player() -> bool:
	return raycast.is_colliding() and raycast.get_collider().is_in_group("player") and enabled

func is_lighting_player() -> bool:
	return (is_raycast_on_player() or is_player_in_area()) and enabled

func _physics_process(delta : float) -> void:
	var players : Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player : Node2D = players[0]
		raycast.target_position = player.global_position - self.global_position + Vector2(0, -8)
		raycast.target_position = raycast.target_position.limit_length(light_range)


func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()