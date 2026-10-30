extends Node


func _on_SizeUp_pressed():
	TouchControls.button_scale += 1


func _on_SizeDown_pressed():
	TouchControls.button_scale = max(TouchControls.button_scale - 1, 2)

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
