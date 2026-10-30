@tool
extends Area2D

const ANIM_SPEED : float = 24.0

@export_node_path("Node2D") var destination
@export var backless : bool:
	set(val):
		$Sprite2D.visible = !val
		backless = val

@onready var sprite_doors : Sprite2D = $Sprite2D_Doors
@onready var sprite_outline : Sprite2D = $Sprite2D_Outline
@onready var audio_open : AudioStreamPlayer2D = $Audio_Open
@onready var timer_close_doors : Timer = $Timer_CloseDoors

var actual_frame : float = 0.0
var target_frame : float = 0.0

func _on_timer_close_doors_timeout() -> void:
	target_frame = 0.0

func get_destination() -> Node2D:
	return get_node(destination)

func make_outline_visible() -> void:
	sprite_outline.modulate.a = 1.0

func open() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()
	audio_open.play()
	target_frame = 5.0
	timer_close_doors.start()

func _physics_process(delta : float) -> void:
	actual_frame = move_toward(actual_frame, target_frame, ANIM_SPEED * delta)
	sprite_doors.frame = actual_frame
	if sprite_outline.modulate.a > 0.0:
		sprite_outline.modulate.a -= delta * 4.0
