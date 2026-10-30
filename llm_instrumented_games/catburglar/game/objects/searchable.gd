extends Area2D

@export var value : float
@export var description : String
@export var search_sound : AudioStream

@onready var audio_searched : AudioStreamPlayer2D = $Audio_Searched

var searched : bool = false

signal looted

func play_search_sound() -> void:
	if search_sound != null:
		audio_searched.play()

func search() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	searched = true
	emit_signal("looted", value, description)

func _ready() -> void:
	if search_sound != null:
		audio_searched.stream = search_sound
