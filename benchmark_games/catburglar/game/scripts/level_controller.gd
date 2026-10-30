extends Node

@export_node_path("Node") var path_scenario
@onready var scenario : Node = get_node(path_scenario)

@export_node_path("Node2D") var path_player
@onready var player : Node2D = get_node(path_player)

@onready var hud : CanvasLayer = $HUD
@onready var audio_stinger : AudioStreamPlayer = $Audio_Stinger

signal complete
signal game_over

func _on_dialogue_trigger_activated(which : String) -> void:
	play_dialogue(which)

func _on_hud_dialogue_finished() -> void:
	await get_tree().create_timer(0.05).timeout # janky hack m8
	player.ignore_inputs = false

func _on_player_caught() -> void:
	audio_stinger.play()
	hud.do_game_over()
	emit_signal("game_over")

func _on_player_started_hacking() -> void:
	hud.start_minigame()

func _on_player_escaped() -> void:
	emit_signal("complete")

func _on_treasure_stolen(value : int) -> void:
	GameProgress.loot += value
	hud.update_loot_value(GameProgress.loot)
	hud.show_loot()
	scenario._on_loot_value_changed(GameProgress.loot)

func _on_searchable_looted(value : int, description : String) -> void:
	GameProgress.loot += value
	hud.update_loot_value(GameProgress.loot)
	hud.show_loot()
	hud.show_loot_description(description)
	scenario._on_loot_value_changed(GameProgress.loot)

func _on_hud_minigame_succeeded() -> void:
	player.stop_hacking(true)

func _on_hud_minigame_failed() -> void:
	player.stop_hacking(false)

func play_dialogue(which : String) -> void:
	if not GameProgress.is_dialogue_played(which):
		hud.start_dialogue(which)
		GameProgress.dialogue_played(which)
		player.ignore_inputs = true

func _physics_process(delta : float) -> void:
	var interact_label : String = player.get_interact_action_label()
	hud.set_prompt(interact_label != &"", interact_label)



func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()