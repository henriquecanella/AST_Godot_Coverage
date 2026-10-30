extends Area2D

var active : bool = false

func become_active() -> void:
	active = true

func _on_body_entered(body : PhysicsBody2D) -> void:
	if body.is_in_group("player") and active:
		body.escape()


func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()