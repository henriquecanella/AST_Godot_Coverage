class_name AutoPlaySprite
extends AnimatedSprite2D

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()
	play()
