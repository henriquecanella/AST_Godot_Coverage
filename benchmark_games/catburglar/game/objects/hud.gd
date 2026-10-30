extends CanvasLayer

enum Visibility {IN_LIGHT, IN_SHADOW, HIDDEN, NIL}

const LOOT_SHOW_TIME : float = 3.0
const OBJECTIVE_SHOW_TIME : float = 6.0
const MOVE_SPEED : float = 4.0

@export_node_path("Node2D") var path_player
@onready var player : Node2D = get_node(path_player)

@onready var oval_visibility : NinePatchRect = $Visibility/Oval
@onready var label_visibility : Label = $Visibility/Label_Visibility_Label
@onready var texture_eye_left : TextureRect = $Visibility/Texture_Eye_Left
@onready var texture_eye_right : TextureRect = $Visibility/Texture_Eye_Right
@onready var label_loot_value : Label = $Loot/Label_Loot_Value
@onready var label_objective_value : Label = $Objective/Label_Objective_Value
@onready var loot : Control = $Loot
@onready var label_loot_description = $Label_LootDescription
@onready var objective : Control = $Objective
@onready var minigame : Node2D = $Minigame
@onready var greyout : ColorRect = $Greyout
@onready var dialogue : Control = $Dialogue
@onready var dialogue_line : Label = $Dialogue/Label_Line
@onready var hint : Control = $Hint
@onready var hint_line : Label = $Hint/Label_Line
@onready var prompt : Control = $Prompt
@onready var prompt_prompt : Control = $Prompt/Prompt # I know. I know.
@onready var timer_hide_hint : Timer = $Timer_HideHint
@onready var timer_hide_loot_description : Timer = $Timer_HideLootDescription
@onready var audio_vo : AudioStreamPlayer = $Audio_VO
@onready var audio_in_light : AudioStreamPlayer = $Audio_InLight
@onready var audio_in_shadow : AudioStreamPlayer = $Audio_InShadow

var loot_show_time : float = 0.0
var objective_show_time : float = 0.0

var current_visibility : int = Visibility.NIL

var game_over : bool = false
var grey_amount : float = 0.0

var playing_dialogue : bool = false

signal minigame_succeeded
signal minigame_failed
signal dialogue_finished

func _on_minigame_succeeded() -> void:
	create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).tween_property(minigame, "position:x", 1440, 0.5)
	emit_signal("minigame_succeeded")

func _on_minigame_failed() -> void:
	create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).tween_property(minigame, "position:x", 1440, 0.5)
	emit_signal("minigame_failed")

func _on_audio_vo_finished() -> void:
	create_tween().tween_property(dialogue, "modulate", Color.TRANSPARENT, 0.25)
	emit_signal("dialogue_finished")
	playing_dialogue = false
	
func _on_timer_hide_hint_timeout() -> void:
	create_tween().tween_property(hint, "modulate", Color.TRANSPARENT, 0.25)

func _on_timer_hide_loot_description_timeout() -> void:
	create_tween().tween_property(label_loot_description, "modulate", Color.TRANSPARENT, 0.25)

func _on_hint_trigger_activated(hint_slug : String):
	show_hint(hint_slug)

func start_minigame() -> void:
	minigame.start()
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).tween_property(minigame, "position:x", 1088, 0.5)

func start_dialogue(which : String) -> void:
	dialogue_line.text = Dialogues.get_dialogue_line(which)
	create_tween().tween_property(dialogue, "modulate", Color.WHITE, 0.25)
	audio_vo.stream = load(Dialogues.get_dialogue_vo_path(which))
	audio_vo.play()
	playing_dialogue = true

func show_hint(which : String) -> void:
	if not GameProgress.is_hint_shown(which):
		hint_line.text = Dialogues.get_hint_line(which)
		create_tween().tween_property(hint, "modulate", Color.WHITE, 0.25)
		GameProgress.hint_shown(which)
		timer_hide_hint.start()

func show_loot_description(desc : String) -> void:
	label_loot_description.text = desc
	create_tween().tween_property(label_loot_description, "modulate", Color.WHITE, 0.25)
	timer_hide_loot_description.start()

func set_prompt(vis : bool, action : String) -> void:
	if playing_dialogue:
		prompt.visible = true
		prompt_prompt.title = &"Skip"
	else:
		prompt.visible = vis
		prompt_prompt.title = action

func do_game_over() -> void:
	game_over = true
	objective.hide()
	loot.hide()

func update_loot_value(loot : int) -> void:
	label_loot_value.text = "$" + str(loot)

func update_objective_value(objective : String) -> void:
	label_objective_value.text = objective

func show_loot() -> void:
	loot_show_time = LOOT_SHOW_TIME

func show_objective() -> void:
	objective_show_time = OBJECTIVE_SHOW_TIME

func get_visibility() -> int:
	if player.lit and !player.obscured and !game_over:
		return Visibility.IN_LIGHT
	elif !player.lit and !game_over:
		return Visibility.IN_SHADOW
	elif player.lit and player.obscured and !game_over:
		return Visibility.HIDDEN
	return Visibility.NIL

func change_visibility(visibility : int) -> void:
	match visibility:
		Visibility.IN_LIGHT:
			oval_visibility.modulate = Color("8b93af")
			get_tree().create_tween().tween_property(oval_visibility, "modulate", Color("333941"), 0.2)
			label_visibility.text = "IN LIGHT"
			audio_in_light.play()
		Visibility.IN_SHADOW:
			label_visibility.text = "IN SHADOW"
			audio_in_shadow.play()
		Visibility.HIDDEN:
			label_visibility.text = "HIDDEN"
	texture_eye_left.visible = visibility == Visibility.IN_LIGHT
	texture_eye_right.visible = visibility == Visibility.IN_LIGHT
	current_visibility = visibility

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("interact") and playing_dialogue:
		audio_vo.stop()
		_on_audio_vo_finished()

func _physics_process(delta : float) -> void:
	if player.should_hud_update_visibility():
		var new_visibility : int = get_visibility()
		if current_visibility != new_visibility:
			change_visibility(new_visibility)
	var loot_target_pos : float = 16.0 if loot_show_time > 0.0 else -32.0
	var objective_target_pos : float = 680.0 if objective_show_time > 0.0 else 720.0
	if loot_show_time > 0.0: loot_show_time -= delta
	if objective_show_time > 0.0: objective_show_time -= delta
	loot.position.y = lerp(loot.position.y, loot_target_pos, MOVE_SPEED * delta)
	objective.position.y = lerp(objective.position.y, objective_target_pos, MOVE_SPEED * delta)
	if game_over:
		grey_amount = clampf(grey_amount + delta, 0.0, 1.0)
		greyout.material.set_shader_parameter("amount", grey_amount)

func _ready() -> void:
	if has_node("Trackable"):
		$Trackable.setup_coverage()
	greyout.material.set_shader_parameter("amount", grey_amount)
