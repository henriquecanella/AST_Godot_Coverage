extends Control

@onready var label_time_taken_value : Label = $GridContainer/Label_TimeTaken_Value
@onready var label_loot_value : Label = $GridContainer/Label_Loot_Value
@onready var label_alerts_value : Label = $GridContainer/Label_Alerts_Value
@onready var label_rank_value : Label = $GridContainer/Label_Rank_Value
@onready var audio_bgm : AudioStreamPlayer = $Audio_BGM
@onready var anim_player : AnimationPlayer = $AnimationPlayer

enum State {IN, THERE, OUT}

var current_state : int = State.IN

func _on_animation_player_animation_finished(anim_name : String) -> void:
	match anim_name:
		"appear":
			current_state = State.THERE
		"disappear":
			if GameProgress.current_level < 2:
				GameProgress.current_level += 1
				get_tree().change_scene_to_file("res://scenes/briefing.tscn")
			else:
				get_tree().change_scene_to_file("res://scenes/ending.tscn")

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("interact") and current_state == State.THERE:
		anim_player.play("disappear")
		current_state = State.OUT

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	label_time_taken_value.text = Utilities.int_to_timestamp(GameProgress.time_taken)
	label_loot_value.text = "$" + str(GameProgress.loot)
	label_alerts_value.text = str(GameProgress.camera_alerts)
	await get_tree().create_timer(0.1).timeout
	audio_bgm.play()
	anim_player.play("appear")
