extends Node

var time_taken : int
var loot : int
var camera_alerts : int
var secondary_objective_met : bool

var current_level : int = 0
var dialogues_played : Array = []
var hints_shown : Array = []

func is_dialogue_played(which : String) -> bool:
	return which in dialogues_played

func dialogue_played(which : String) -> void:
	dialogues_played.append(which)

func is_hint_shown(which : String) -> bool:
	return which in hints_shown

func hint_shown(which : String) -> void:
	hints_shown.append(which)

func new_game() -> void:
	current_level = 0
	dialogues_played = []

func start_level() -> void:
	loot = 0
	camera_alerts = 0
	secondary_objective_met = false


func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()