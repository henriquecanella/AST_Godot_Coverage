extends Node2D

const THINKING_TIME : float = 0.5
const ALARM_TIME : float = 3.0

@onready var sprite : Sprite2D = $Sprite2D
@onready var light : PointLight2D = $PointLight2D
@onready var raycasts : Node2D = $Raycasts
@onready var audio_sight : AudioStreamPlayer2D = $Audio_Sight
@onready var audio_nevermind : AudioStreamPlayer2D = $Audio_Nevermind
@onready var audio_alarm : AudioStreamPlayer2D = $Audio_Alarm
@onready var audio_move : AudioStreamPlayer2D = $Audio_Move

enum State {WATCHING, MOVING, MAYBE, ALARM}

@export var pointed : Vector2 = Vector2.LEFT
@export var wait_time : float = 4.0

var current_state : int = State.WATCHING
var anim_index : float = 0.0

func can_see_player() -> bool:
	var collider : Node2D = get_raycast_collider()
	if collider != null:
		if collider.is_in_group("player") and collider.can_be_spotted():
			return true
	return false

func get_player() -> Node2D:
	var collider : Node2D = get_raycast_collider()
	if collider != null:
		if collider.is_in_group("player") and collider.can_be_spotted():
			return collider
	return null

func get_raycast_collider() -> Node2D:
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return raycast.get_collider()
	return null

func _physics_process_watching(delta : float) -> void:
	sprite.frame = 0 if pointed == Vector2.LEFT else 2
	light.enabled = true
	light.color = Color.GREEN_YELLOW
	light.scale.x = -pointed.x
	anim_index += delta
	if can_see_player():
		current_state = State.MAYBE
		anim_index = 0.0
		audio_sight.play()
	elif anim_index >= wait_time:
		current_state = State.MOVING
		anim_index = 0.0
		pointed.x *= -1.0
		raycasts.scale.x *= -1.0
		audio_move.play()

func _physics_process_moving(delta : float) -> void:
	light.enabled = false
	anim_index += delta * 4.0
	if pointed == Vector2.LEFT:
		sprite.frame = 7.9 - clampf(anim_index, 0.0, 3.0)
	else:
		sprite.frame = 4 + clampf(anim_index, 0.0, 3.0)
	if anim_index >= 4.0:
		current_state = State.WATCHING
		anim_index = 0.0

func _physics_process_maybe(delta : float) -> void:
	anim_index += delta
	if fmod(anim_index, 0.2) > 0.1:
		sprite.frame = 0 if pointed == Vector2.LEFT else 2
		light.color = Color.GREEN_YELLOW
	else:
		sprite.frame = 1 if pointed == Vector2.LEFT else 3
		light.color = Color.ORANGE_RED
	if anim_index >= THINKING_TIME:
		if can_see_player():
			current_state = State.ALARM
			anim_index = 0.0
			audio_alarm.play()
			GameProgress.camera_alerts += 1
			get_player().camera_alerted()
		else:
			current_state = State.WATCHING
			anim_index = 0.0
			audio_nevermind.play()

func _physics_process_alarm(delta : float) -> void:
	light.color = Color.ORANGE_RED
	anim_index += delta
	if fmod(anim_index, 0.2) > 0.1:
		sprite.frame = 4 if pointed == Vector2.LEFT else 7
		light.enabled = false
	else:
		sprite.frame = 1 if pointed == Vector2.LEFT else 3
		light.enabled = true
	if anim_index >= ALARM_TIME:
		current_state = State.WATCHING
		anim_index = 0.0

func _physics_process(delta : float) -> void:
	match current_state:
		State.WATCHING: _physics_process_watching(delta)
		State.MOVING: _physics_process_moving(delta)
		State.MAYBE: _physics_process_maybe(delta)
		State.ALARM: _physics_process_alarm(delta)

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()
	raycasts.scale.x = -pointed.x
