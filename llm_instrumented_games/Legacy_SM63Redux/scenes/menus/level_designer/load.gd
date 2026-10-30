extends Button

@onready var dialog = $"/root/Main/UILayer/OpenDialog"


func _on_Open_pressed():
	dialog.popup_centered_ratio(0.75)

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
