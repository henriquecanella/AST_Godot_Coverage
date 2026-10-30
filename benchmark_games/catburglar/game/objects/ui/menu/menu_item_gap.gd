extends Control

var skip_cursor : bool = true


func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()