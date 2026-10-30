extends Control

@onready var item_grid = $ItemPane/ItemBlock/ItemScroll
@onready var polygon_grid = $ItemPane/ItemBlock/PolygonScroll


func _on_Mode_pressed():
	item_grid.visible = !item_grid.visible
	polygon_grid.visible = !item_grid.visible

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()
