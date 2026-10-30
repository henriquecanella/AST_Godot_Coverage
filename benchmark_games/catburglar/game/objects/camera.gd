extends Camera2D

const MOVE_SPEED : float = 4.0

@export_node_path("Node2D") var player

var override : bool = false
var override_position : Vector2

func zoom_in() -> void:
	create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).tween_property(self, "zoom", Vector2(6, 6), 1.0)

func zoom_out() -> void:
	create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).tween_property(self, "zoom", Vector2(3, 3), 2.0)

func _process(delta : float) -> void:
	var target_position : Vector2
	if not override:
		var p : Node2D = get_node(player)
		target_position = p.global_position
	else:
		target_position = override_position
	global_position = lerp(global_position, target_position, MOVE_SPEED * delta)


func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()