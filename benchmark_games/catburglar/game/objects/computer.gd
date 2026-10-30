@tool
extends Area2D

@export var desk_sprite : Texture2D:
	set(val):
		$Sprite2D.texture = val
		desk_sprite = val

var hacked : bool = false:
	set(val):
		hacked = val
		if hacked and has_node("Trackable"):
			$Trackable.setup_coverage()
