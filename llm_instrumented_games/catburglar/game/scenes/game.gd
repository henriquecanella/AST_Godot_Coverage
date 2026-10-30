extends Node

@onready var audio_bgm : AudioStreamPlayer = $Audio_BGM
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var timer_restart_level : Timer = $Timer_RestartLevel
@onready var pause_screen : Control = $CanvasLayer/PauseScreen

enum State {IN_GAME, PAUSED, GAME_OVER, LEVEL_COMPLETE}

var level : Node
var current_state : int = State.IN_GAME

func _on_level_complete() -> void:
	get_tree().paused = true
	Utilities.pause_timer()
	GameProgress.time_taken = Utilities.get_time_taken_msec()
	current_state = State.LEVEL_COMPLETE
	anim_player.play("anim_out")

func _on_level_game_over() -> void:
	timer_restart_level.start()

func _on_timer_restart_level_timeout() -> void:
	current_state = State.GAME_OVER
	anim_player.play("anim_out")

func _on_animation_player_animation_finished(anim_name : String) -> void:
	match anim_name:
		"anim_out":
			if current_state == State.GAME_OVER:
				level.queue_free()
				level = null
				spawn_level()
				anim_player.play("anim_in")
			elif current_state == State.LEVEL_COMPLETE:
				get_tree().paused = false
				get_tree().change_scene_to_file("res://scenes/level_complete.tscn")

func _on_pause_screen_exited() -> void:
	get_tree().paused = false
	current_state = State.IN_GAME

func spawn_level() -> void:
	var scene : PackedScene = load(Constants.get_level_scene_path(GameProgress.current_level))
	level = scene.instantiate()
	level.connect("complete", _on_level_complete)
	level.connect("game_over", _on_level_game_over)
	add_child(level)
	current_state = State.IN_GAME
	GameProgress.start_level()
	Utilities.start_timer()

func pause() -> void:
	get_tree().paused = true
	current_state = State.PAUSED
	pause_screen.appear()

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("pause") and current_state == State.IN_GAME:
		pause()

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	spawn_level()
	anim_player.play("anim_in")
	audio_bgm.stream = load(Constants.get_level_music_path(GameProgress.current_level))
	audio_bgm.play()

