@tool
extends Area2D

@export var desk_sprite : Texture2D:
	set(val):
		$Sprite2D.texture = val
		desk_sprite = val

func is_hiding_player() -> bool:
	var bodies : Array[Node2D] = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			return true
	return false


func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()