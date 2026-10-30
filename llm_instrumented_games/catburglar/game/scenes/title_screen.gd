extends Control

enum State {WARMUP, INTRO, MENU, SETTINGS, CREDITS, FADE_OUT_GAME, FADE_OUT_QUIT}
enum Menu {MAIN, CREDITS, SETTINGS, GRAPHICS, AUDIO, CONTROLS}

@onready var logo : Control = $Logo
@onready var title_menu : Control = $Menus/Title
@onready var settings_menu : Control = $Menus/Settings
@onready var graphics_menu : Control = $Menus/Graphics
@onready var audio_menu : Control = $Menus/Audio
@onready var controls_menu : Control = $Menus/Controls
@onready var credits : Control = $Credits
@onready var video_player : VideoStreamPlayer = $VideoStreamPlayer
@onready var audio_bgm : AudioStreamPlayer = $Audio_BGM
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var prompt_select : Control = $Prompts/Prompt_Select
@onready var prompt_back : Control = $Prompts/Prompt_Back

var current_state : int = State.WARMUP

func set_active_menu(menu : int) -> void:
	title_menu.visible = menu == Menu.MAIN
	title_menu.active = menu == Menu.MAIN
	credits.visible = menu == Menu.CREDITS
	settings_menu.visible = menu == Menu.SETTINGS
	settings_menu.active = menu == Menu.SETTINGS
	graphics_menu.visible = menu == Menu.GRAPHICS
	graphics_menu.active = menu == Menu.GRAPHICS
	audio_menu.visible = menu == Menu.AUDIO
	audio_menu.active = menu == Menu.AUDIO
	controls_menu.visible = menu == Menu.CONTROLS
	controls_menu.active = menu == Menu.CONTROLS
	prompt_select.visible = menu != Menu.CREDITS
	prompt_back.visible = menu != Menu.MAIN

func _on_title_button_pressed(button_id : String) -> void:
	match button_id:
		"play":
			current_state = State.FADE_OUT_GAME
			title_menu.active = false
			anim_player.play("fade_out")
			#SoundController.play_sound("ui_start")
		"settings":
			set_active_menu(Menu.SETTINGS)
			current_state = State.SETTINGS
		"credits":
			set_active_menu(Menu.CREDITS)
			current_state = State.CREDITS
		"quit":
			current_state = State.FADE_OUT_QUIT
			title_menu.active = false
			anim_player.play("fade_out")

func _on_settings_button_pressed(button_id : String) -> void:
	match button_id:
		"graphics":
			set_active_menu(Menu.GRAPHICS)
		"audio":
			set_active_menu(Menu.AUDIO)
		"controls":
			set_active_menu(Menu.CONTROLS)

func _on_settings_closed() -> void:
	set_active_menu(Menu.MAIN)

func _on_graphics_closed() -> void:
	set_active_menu(Menu.SETTINGS)

func _on_audio_closed() -> void:
	set_active_menu(Menu.SETTINGS)

func _on_controls_closed() -> void:
	set_active_menu(Menu.SETTINGS)

func _on_animation_player_animation_finished(anim_name : String) -> void:
	match anim_name:
		"fade_in":
			current_state = State.MENU
			set_active_menu(Menu.MAIN)
		"fade_out":
			match current_state:
				State.FADE_OUT_GAME:
					GameProgress.new_game()
					get_tree().change_scene_to_file("res://scenes/briefing.tscn")
				State.FADE_OUT_QUIT:
					get_tree().quit()

func _on_video_stream_player_finished() -> void:
	video_player.play()

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		match current_state:
			State.CREDITS:
				set_active_menu(Menu.MAIN)
				current_state = State.MENU
	elif event.is_action_pressed("interact"):
		match current_state:
			State.INTRO:
				anim_player.seek(10.0, true)
				current_state = State.MENU
				title_menu.active = true

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	if OS.get_name() == "Web":
		$Menus/Title/Quit.queue_free()
	await get_tree().create_timer(1.0).timeout
	current_state = State.INTRO
	audio_bgm.play()
	anim_player.play("fade_in")
