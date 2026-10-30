extends Area2D

signal door_entered()

func _on_body_entered(_body):
	$Trackable.mark_interacted()
	print("door_entered")
	door_entered.emit()
