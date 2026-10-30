class_name Campfire
extends Node2D

enum CampfireMode {
	Ignite,
	AlwaysIgnited,
	NeverIgnited,
}

@export var anim: AnimationPlayer
@export var mode: CampfireMode

func _ready() -> void:
	if anim:
		anim.animation_started.connect(
			func(anim_name: StringName):
				if anim_name == "ignite" or anim_name == "idle_ignited":
					if has_node("Trackable"):
						$Trackable.mark_interacted()
		)
