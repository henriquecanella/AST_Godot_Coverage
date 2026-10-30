class_name CoinPickupYellow
extends CoinPickup


func _award_pickup(_body) -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()
	_add_coins(1, _body)
