extends Control

@onready var label_coins = $LabelCoins
@onready var label_fairies = $LabelFairies
@onready var label_kills = $LabelKills

func _process(_delta):
	if (Global.player_coins > 0 or Global.player_fairies > 0 or Global.player_kills > 0) and has_node("Trackable"):
		$Trackable.mark_interacted()
	label_coins.text = "COINS: " + str(Global.player_coins)
	label_fairies.text = "FAIRIES: " + str(Global.player_fairies)
	label_kills.text = "KILLS: " + str(Global.player_kills)
	
