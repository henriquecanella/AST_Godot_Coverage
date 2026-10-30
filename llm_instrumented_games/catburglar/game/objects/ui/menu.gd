extends VBoxContainer

var current_item : int = 0
var active : bool = false

signal item_selected
signal back

func update_buttons() -> void:
	for i in range(0, get_child_count()):
		if get_child(i) is Control:
			get_child(i).modulate = Color.WHITE if current_item == i else Color(1.0, 1.0, 1.0, 0.5)

func change_current_item(diff : int) -> void:
	current_item = wrapi(current_item + diff, 0, get_child_count())
	if not (get_child(current_item) is Control):
		current_item = wrapi(current_item + diff, 0, get_child_count())
	update_buttons()

func _input(event : InputEvent) -> void:
	if not active: return
	if event.is_action_pressed("up"):
		change_current_item(-1)
	elif event.is_action_pressed("down"):
		change_current_item(1)
	elif event.is_action_pressed("interact") or event.is_action_pressed("pause"):
		emit_signal("item_selected", get_child(current_item).name)
	elif event.is_action_pressed("shoot"):
		emit_signal("back")

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	update_buttons()
