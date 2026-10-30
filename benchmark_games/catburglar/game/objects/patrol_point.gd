extends Node2D

@export var wait_time : float = 1.0
@export var sleep_time : float = 0.0


func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()