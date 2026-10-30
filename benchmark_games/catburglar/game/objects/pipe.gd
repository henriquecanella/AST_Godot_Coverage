extends Area2D

@export var journey : Path2D
@export var destination : Node2D
@export var exit_facing : Vector2

func _on_body_entered(body : PhysicsBody2D) -> void:
	if body.is_in_group("player"):
		var path_points : Array = []
		for i in range(0, journey.curve.point_count):
			path_points.append(journey.curve.get_point_position(i))
		body.enter_pipe(path_points, self, destination, exit_facing)


func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()