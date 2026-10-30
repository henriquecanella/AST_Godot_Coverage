class_name CoinPickupYellow
extends CoinPickup


func _award_pickup(_body) -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	_add_coins(1, _body)
