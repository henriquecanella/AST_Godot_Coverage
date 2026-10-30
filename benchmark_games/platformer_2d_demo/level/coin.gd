class_name Coin extends Area2D
## Collectible that disappears when the player touches it.


@onready var animation_player := $AnimationPlayer as AnimationPlayer


func _on_body_entered(body: Node2D) -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()
	animation_player.play(&"picked")
	(body as Player).coin_collected.emit()
