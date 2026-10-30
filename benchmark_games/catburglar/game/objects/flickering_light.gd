extends PointLight2D

@export var light_range : float
@export var timings : Array[float]

@onready var raycast : RayCast2D = $RayCast2D

var current_timing : int
var time_until_change : float

func is_lighting_player() -> bool:
	return raycast.is_colliding() and raycast.get_collider().is_in_group("player") and enabled

func _physics_process(delta : float) -> void:
	var players : Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player : Node2D = players[0]
		raycast.target_position = player.global_position - self.global_position
		raycast.target_position = raycast.target_position.limit_length(light_range)
	time_until_change -= delta
	if time_until_change <= 0.0:
		current_timing = wrapi(current_timing + 1, 0, timings.size())
		time_until_change = timings[current_timing]
		enabled = !enabled

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()
	current_timing = 0
	time_until_change = timings[0]
