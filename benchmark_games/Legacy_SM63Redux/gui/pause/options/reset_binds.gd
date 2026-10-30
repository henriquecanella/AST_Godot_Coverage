extends TextureButton


func _on_ResetBinds_pressed():
	var map = Singleton.default_input_map
	Singleton.load_input_map(map)
	Singleton.save_input_map(map)
	Singleton.get_node("SFX/Back").play()

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()
