extends Area2D

@export var slug : String

var triggered : bool = false

signal activated

func _on_body_entered(body : PhysicsBody2D) -> void:
	if body.is_in_group("player") and not triggered:
		emit_signal("activated", slug)
		triggered = true


func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()