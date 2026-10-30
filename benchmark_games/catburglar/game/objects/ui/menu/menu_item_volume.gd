@tool
extends HBoxContainer

@export var id : String

@export var title : String = "Menu Title" :
	set(value):
		$Label.text = value
		title = value

var skip_cursor : bool = false

var amount : int = 10

func activate() -> void:
	pass

func increase() -> void:
	amount = clampi(amount + 1, 0, 10)
	$Volume.texture.region.position.y = amount * 54
	Settings.set_volume_setting(id, amount)
	#SoundController.play_sound("ui_volume")

func decrease() -> void:
	amount = clampi(amount - 1, 0, 10)
	$Volume.texture.region.position.y = amount * 54
	Settings.set_volume_setting(id, amount)
	#SoundController.play_sound("ui_volume")

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()
	amount = Settings.get_volume_setting(id)
	$Volume.texture = $Volume.texture.duplicate(true)
	$Volume.texture.region.position.y = amount * 54
