extends Node

@export_node_path("Node") var path_level_controller
@onready var level_controller : Node = get_node(path_level_controller)

@export_node_path("CanvasLayer") var path_hud
@onready var hud : CanvasLayer = get_node(path_hud)

@export_node_path("Node2D") var path_level_exit
@onready var level_exit : Node2D = get_node(path_level_exit)

var objective_complete : bool = false
var secondary_objective_complete : bool = false
var computers_hacked : int = 0

func _on_loot_value_changed(loot : int) -> void:
	pass

func _on_player_vase_smashed() -> void:
	hud.update_objective_value("Escape.")
	hud.show_objective()
	objective_complete = true
	level_exit.become_active()
	level_controller.play_dialogue("level3_vase")

func _on_hud_minigame_succeeded() -> void:
	computers_hacked += 1
	if computers_hacked >= 3:
		GameProgress.secondary_objective_met = true
		hud.update_objective_value("Secondary objective complete.")
		hud.show_objective()

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	hud.update_objective_value("Find the vase.")
	hud.show_objective()

