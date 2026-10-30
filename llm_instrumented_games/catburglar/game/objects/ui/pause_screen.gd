extends Control

enum State {INACTIVE, ANIM_IN, ACTIVE, SETTINGS, ANIM_OUT_RESUME, ANIM_OUT_RESTART, ANIM_OUT_TITLE}
enum Menu {PAUSE, SETTINGS, GRAPHICS, AUDIO, CONTROLS}

var current_state : int = State.INACTIVE

@onready var pause_menu : Control = $Menus/Pause
@onready var settings_menu : Control = $Menus/Settings
@onready var graphics_menu : Control = $Menus/Graphics
@onready var audio_menu : Control = $Menus/Audio
@onready var controls_menu : Control = $Menus/Controls
@onready var anim_player : AnimationPlayer = $AnimationPlayer

signal exited

func set_active_menu(menu : int) -> void:
	pause_menu.visible = menu == Menu.PAUSE
	pause_menu.active = menu == Menu.PAUSE
	settings_menu.visible = menu == Menu.SETTINGS
	settings_menu.active = menu == Menu.SETTINGS
	graphics_menu.visible = menu == Menu.GRAPHICS
	graphics_menu.active = menu == Menu.GRAPHICS
	audio_menu.visible = menu == Menu.AUDIO
	audio_menu.active = menu == Menu.AUDIO
	controls_menu.visible = menu == Menu.CONTROLS
	controls_menu.active = menu == Menu.CONTROLS

func appear() -> void:
	anim_player.play("appear")
	current_state = State.ANIM_IN

func _on_pause_button_pressed(button_id : String) -> void:
	match button_id:
		"resume":
			anim_player.play("disappear")
			current_state = State.ANIM_OUT_RESUME
			pause_menu.active = false
			pause_menu.hide()
			#SoundController.play_sound("ui_start")
		"restart_level":
			anim_player.play("exit")
			current_state = State.ANIM_OUT_RESTART
			pause_menu.active = false
			pause_menu.hide()
			#SoundController.play_sound("ui_start")
		"settings":
			set_active_menu(Menu.SETTINGS)
			current_state = State.SETTINGS
		"back_to_title":
			anim_player.play("exit")
			current_state = State.ANIM_OUT_TITLE
			pause_menu.active = false
			pause_menu.hide()

func _on_settings_button_pressed(button_id : String) -> void:
	match button_id:
		"graphics":
			set_active_menu(Menu.GRAPHICS)
		"audio":
			set_active_menu(Menu.AUDIO)
		"controls":
			set_active_menu(Menu.CONTROLS)

func _on_pause_closed() -> void:
	anim_player.play("disappear")
	current_state = State.ANIM_OUT_RESUME
	pause_menu.active = false
	pause_menu.hide()

func _on_settings_closed() -> void:
	set_active_menu(Menu.PAUSE)

func _on_graphics_closed() -> void:
	set_active_menu(Menu.SETTINGS)

func _on_audio_closed() -> void:
	set_active_menu(Menu.SETTINGS)

func _on_controls_closed() -> void:
	set_active_menu(Menu.SETTINGS)

func _on_animation_player_animation_finished(anim_name : String) -> void:
	match anim_name:
		"appear":
			current_state = State.ACTIVE
			set_active_menu(Menu.PAUSE)
		"disappear":
			current_state = State.INACTIVE
			emit_signal("exited")
		"exit":
			get_tree().paused = false
			if current_state == State.ANIM_OUT_RESTART:
				get_tree().reload_current_scene()
			else:
				get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()