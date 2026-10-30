class_name CoinPickupRed
extends CoinPickup


func _award_pickup(_body) -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	_add_coins(2, _body)
	Singleton.red_coin_total += 1
