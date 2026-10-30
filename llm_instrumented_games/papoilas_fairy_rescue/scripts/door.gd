extends Area2D

signal door_entered()

func _on_body_entered(_body):
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	print("door_entered")
	door_entered.emit()
