extends Node2D

const MAX_TIME : float = 5.0

enum State {INACTIVE, ACTIVE}

@onready var arrow_up : Sprite2D = $Arrow_Up
@onready var arrow_down : Sprite2D = $Arrow_Down
@onready var arrow_left : Sprite2D = $Arrow_Left
@onready var arrow_right : Sprite2D = $Arrow_Right
@onready var sprite_progress : Sprite2D = $Progress
@onready var sprite_timer : Sprite2D = $Timer
@onready var audio_bgm : AudioStreamPlayer = $Audio_BGM
@onready var audio_yes : AudioStreamPlayer = $Audio_Yes
@onready var audio_no : AudioStreamPlayer = $Audio_No

var current_state : int
var time_left : float
var progress : int
var arrow_to_press : Vector2 = Vector2.ZERO

signal succeeded
signal failed

func start() -> void:
	current_state = State.ACTIVE
	time_left = MAX_TIME
	progress = 0
	arrow_to_press = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT].pick_random()
	update_arrows()
	sprite_progress.frame = 0
	audio_bgm.play()

func update_arrows() -> void:
	arrow_up.visible = arrow_to_press == Vector2.UP
	arrow_down.visible = arrow_to_press == Vector2.DOWN
	arrow_left.visible = arrow_to_press == Vector2.LEFT
	arrow_right.visible = arrow_to_press == Vector2.RIGHT

func _physics_process(delta : float) -> void:
	if current_state != State.ACTIVE:
		return
	time_left -= delta
	sprite_timer.scale.x = time_left / MAX_TIME
	if time_left <= 0.0:
		current_state = State.INACTIVE
		emit_signal("failed")
		audio_no.play()
		audio_bgm.stop()
	var input : Vector2 = Vector2.ZERO
	if Input.is_action_just_pressed("up"): input = Vector2.UP
	if Input.is_action_just_pressed("down"): input = Vector2.DOWN
	if Input.is_action_just_pressed("left"): input = Vector2.LEFT
	if Input.is_action_just_pressed("right"): input = Vector2.RIGHT
	if input != Vector2.ZERO:
		if input == arrow_to_press:
			progress += 1
			sprite_progress.frame = progress
			audio_yes.play()
			if progress == 5:
				arrow_to_press = Vector2.ZERO
				emit_signal("succeeded")
				current_state = State.INACTIVE
				audio_bgm.stop()
			else:
				arrow_to_press = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT].pick_random()
				audio_no.play()
		else:
			pass
		update_arrows()


func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()