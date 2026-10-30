class_name CoinPickupBlue
extends CoinPickup


func _award_pickup(_body) -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()
	_add_coins(5, _body)
