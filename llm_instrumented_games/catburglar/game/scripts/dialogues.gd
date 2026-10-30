extends Node

const DIALOGUE_LINES : Dictionary = {
	"level1_guard": {"line": "Good to see Cronjager's still finding work, but those eyes of his aren't doing him any favours. As long as I'm in the dark, I'm invisible."},
	"level1_platform": {"line": "I hate to admit it, but I'm no jumper. I can drop down from here, but getting back up will be harder..."},
	"level1_box": {"line": "That box could make for a nice bit of cover. A little small, but you know the saying: if I fits..."},
	"level1_camera": {"line": "Using last year's security cameras, Harry? How embarrassing."},
	"level1_computer": {"line": "Oh, Harry... still young at heart, I see. But your selfie game needs work. I'll just take a copy of these; they'll make for good insurance."},
	"level1_goal": {"line": "That should be enough. I can see myself out... or I can stick around and really make this worth my while."},
	"level2_guard": {"line": "Aw, Cronjager... burning the midnight oil again? Someone hasn't had his coffee. I could make use of that."},
	"level2_statue": {"line": "Talk about still life..."},
	"level2_poster": {"line": "*sigh* I was really looking forward to that movie..."},
	"level2_vent1": {"line": "That vent looks large enough to fit in. It's not graceful, but it's the best way of getting about completely undetected."},
	"level2_vent2": {"line": "Completely. Un. Detected."},
	"level2_computer": {"line": "Holding out on Uncle Sam, are we, Chandler? Cab drivers pay more tax than that."},
	"level2_goal": {"line": "Well, aren't you a pretty little thing. Lighter than I was expecting, too..."},
	"level3_vase": {"line": "Hope it was worth it, Chandler."}
}

const HINT_LINES : Dictionary = {
	"cover": "Furniture that is positioned in front of Cynth can act as cover. Duck while in front of it to remind out of sight.",
	"toggle": "Some lamps can be turned off if you can reach them, making it much easier to go unnoticed.",
	"search": "Remember to search anything that looks like it might contain valuables. You never know what you'll find.",
	"roll_under": "While rolling, tap the crouch button again to roll underneath stairs or thin platforms.",
	"short_roll": "You can interrupt your roll mid-way by tapping the Interact button.",
	"venting": "To enter a vent, roll into it.",
	"blind_cameras": "Cameras can't see you in the dark. Turn the environment to your adventage...",
}

func get_dialogue_line(which : String) -> String:
	return DIALOGUE_LINES[which]["line"]

func get_dialogue_vo_path(which : String) -> String:
	return "res://audio/vo/" + which + ".ogg"

func get_hint_line(which : String) -> String:
	return HINT_LINES[which]


func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()