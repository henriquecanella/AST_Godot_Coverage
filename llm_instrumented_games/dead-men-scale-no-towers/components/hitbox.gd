class_name Hitbox
extends Area2D

func _ready() -> void:
	monitorable = true
	monitoring = false
	collision_layer = 16
	area_entered.connect(_on_entered)
	body_entered.connect(_on_entered)

func _on_entered(_other) -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()

