extends Node

var time_taken : int
var last_active_start_time : int

func int_to_timestamp(value : int) -> String:
	var milliseconds : int = value % 1000
	var seconds : int = (value / 1000) % 60
	var minutes : int = (value / 60000) % 60
	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]

func get_time_taken_msec() -> int:
	return time_taken

func start_timer() -> void:
	last_active_start_time = Time.get_ticks_msec()
	time_taken = 0

func pause_timer() -> void:
	time_taken += Time.get_ticks_msec() - last_active_start_time

func resume_timer() -> void:
	last_active_start_time = Time.get_ticks_msec()
	time_taken += Time.get_ticks_msec() - last_active_start_time


func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()