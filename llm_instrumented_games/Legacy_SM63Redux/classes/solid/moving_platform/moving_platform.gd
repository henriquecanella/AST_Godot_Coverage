extends StaticBody2D

@onready var ride_area = $RideArea

var prev_position = position


func _physics_process(_delta):
	var move_vec = position - prev_position
	for body in ride_area.get_overlapping_bodies():
		if body.is_on_floor() and !$InsideArea.overlaps_body(body):
			if has_node("Trackable"):
				$Trackable.mark_interacted()
			body.position += move_vec
			pass
	prev_position = position
