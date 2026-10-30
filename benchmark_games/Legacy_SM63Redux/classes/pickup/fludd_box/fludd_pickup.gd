class_name FluddPickup
extends Pickup

enum Nozzles {
	HOVER = Singleton.Nozzles.HOVER,
	ROCKET = Singleton.Nozzles.ROCKET,
	TURBO = Singleton.Nozzles.TURBO
}

@export var nozzle_award: Nozzles


func _award_pickup(body):
	if has_node("Trackable"):
		$Trackable.setup_coverage()
	body.current_nozzle = nozzle_award
	body.water = max(body.water, 100)
	queue_free()
