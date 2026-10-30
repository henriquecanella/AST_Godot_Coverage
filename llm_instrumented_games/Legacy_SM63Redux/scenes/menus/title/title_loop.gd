extends AudioStreamPlayer

var played = false


func _process(_delta): # Workaround to allow the music to play at the right time
	if !played:
		play()
		played = true

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
