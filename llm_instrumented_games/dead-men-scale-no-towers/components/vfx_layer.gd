extends CanvasLayer

@export var screen_shake_strong_layer: ColorRect
@export var screen_shake_weak_layer: ColorRect

func shake_weak(enabled: bool) -> void:
	if enabled and has_node("Trackable"):
		$Trackable.mark_interacted()
	screen_shake_weak_layer.visible = enabled

func shake_strong(enabled: bool) -> void:
	if enabled and has_node("Trackable"):
		$Trackable.mark_interacted()
	screen_shake_strong_layer.visible = enabled
