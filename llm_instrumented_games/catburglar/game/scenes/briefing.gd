extends Control

@onready var label_level_name : Label = $Label_LevelName
@onready var label_level_description : Label = $VBox/Label_Description
@onready var label_level_objectives : Label = $VBox/Label_Objectives
@onready var audio_vo : AudioStreamPlayer = $Audio_VO
@onready var audio_bgm : AudioStreamPlayer = $Audio_BGM
@onready var anim_player : AnimationPlayer = $AnimationPlayer

enum State {IN, THERE, OUT}

var current_state : int = State.IN

func _on_animation_player_animation_finished(anim_name : String) -> void:
	match anim_name:
		"appear":
			current_state = State.THERE
		"disappear":
			get_tree().change_scene_to_file("res://scenes/game.tscn")

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("interact") and current_state == State.THERE:
		anim_player.play("disappear")
		current_state = State.OUT

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	label_level_name.text = Constants.get_level_name(GameProgress.current_level)
	label_level_description.text = Constants.get_level_briefing(GameProgress.current_level)
	label_level_objectives.text = Constants.get_level_objectives(GameProgress.current_level)
	audio_vo.stream = load(Constants.get_level_vo_path(GameProgress.current_level))
	await get_tree().create_timer(0.1).timeout
	audio_bgm.play()
	anim_player.play("appear")

