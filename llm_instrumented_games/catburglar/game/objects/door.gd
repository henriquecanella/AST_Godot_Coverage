extends Area2D

const ANIM_SPEED : float = 24.0

@export_node_path("Node2D") var destination

@onready var sprite : Sprite2D = $Sprite2D
@onready var sprite_outline : Sprite2D = $Sprite2D_Outline
@onready var audio_open : AudioStreamPlayer2D = $Audio_Open
@onready var timer_close_door : Timer = $Timer_CloseDoor

var actual_frame : float = 0.0
var target_frame : float = 0.0

func _on_timer_close_door_timeout() -> void:
	target_frame = 0.0

func get_destination() -> Node2D:
	return get_node(destination)

func make_outline_visible() -> void:
	sprite_outline.modulate.a = 1.0

func open() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	audio_open.play()
	target_frame = 6.0
	timer_close_door.start()

func _physics_process(delta : float) -> void:
	actual_frame = move_toward(actual_frame, target_frame, ANIM_SPEED * delta)
	sprite.frame = actual_frame
	if sprite_outline.modulate.a > 0.0:
		sprite_outline.modulate.a -= delta * 4.0

func _ready() -> void:
	if scale.x == -1.0:
		sprite_outline.flip_h = true
