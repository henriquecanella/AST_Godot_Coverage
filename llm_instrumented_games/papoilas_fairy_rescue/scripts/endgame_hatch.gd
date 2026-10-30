extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.connect("open_hatch", _on_open_hatch)

func _on_open_hatch():
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	queue_free()
