extends VBoxContainer

const PREFAB_REBIND_OPTION = preload("res://gui/pause/options/rebind_option.tscn")


func _ready():
	if has_node("Trackable"):
		$Trackable.setup_coverage()
	for action in Singleton.WHITELISTED_ACTIONS:
		var inst = PREFAB_REBIND_OPTION.instantiate()
		inst.action_id = action
		add_child(inst)
