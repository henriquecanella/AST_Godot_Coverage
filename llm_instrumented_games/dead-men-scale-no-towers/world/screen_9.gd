extends Screen

@export var rita: Rita

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	super._ready()
