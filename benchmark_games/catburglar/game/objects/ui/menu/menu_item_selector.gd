@tool
extends HBoxContainer

@export var id : String

@export var title : String = "Menu Title" :
	set(value):
		$Label.text = value
		title = value

@export var values : Array[String] :
	set(value):
		if has_node("Value"):
			$Value.text = value[0]
		values = value

var skip_cursor : bool = false

var selection : int = 0

func activate() -> void:
	pass

func increase() -> void:
	selection = wrapi(selection + 1, 0, len(values))
	$Value.text = values[selection]
	Settings.set_selector_setting(id, selection)

func decrease() -> void:
	selection = wrapi(selection - 1, 0, len(values))
	$Value.text = values[selection]
	Settings.set_selector_setting(id, selection)

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()
	selection = Settings.get_selector_setting(id)
	$Value.text = values[selection]
