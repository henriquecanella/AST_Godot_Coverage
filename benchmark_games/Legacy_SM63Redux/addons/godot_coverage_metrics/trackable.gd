extends Node

class_name Trackable

@export var object_id = ""
@export_enum("PLAYER", "ENEMY", "COLLECTABLE", "NPC", "INTERACTABLE", "HAZARD", "OTHER") var object_type: int = 0

var instance_key = ""
var _autoload_ref: Node = null

func _get_autoload() -> Node:
	if _autoload_ref: return _autoload_ref
	if Engine.get_main_loop() and Engine.get_main_loop().root.has_node("PluginAutoload"):
		_autoload_ref = Engine.get_main_loop().root.get_node("PluginAutoload")
	elif is_inside_tree() and get_tree().root.has_node("PluginAutoload"):
		_autoload_ref = get_tree().root.get_node("PluginAutoload")
	return _autoload_ref

func _ready() -> void:
	var scene_name = get_tree().current_scene.name if get_tree().current_scene else "UnknownScene"
	
	var autoload = _get_autoload()
	if autoload:
		instance_key = autoload.register_node(
			object_id, object_type, get_parent().get_path(), scene_name
		)
	else:
		printerr("Trackable: Could not find PluginAutoload singleton.")

	if get_parent().get_script() != null:
		call_deferred("_do_setup_coverage")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_level"):
		get_tree().reload_current_scene()

func mark_interacted() -> void:
	var autoload = _get_autoload()
	if autoload and instance_key != "":
		autoload.mark_interacted(instance_key)

# The user explicitly asked to maintain setup_coverage to be called manually.
# If they call setup_coverage manually as the interaction, let's map it to mark_interacted!
func setup_coverage() -> void:
	mark_interacted()

# The actual instrumentation is now renamed to _do_setup_coverage
func _do_setup_coverage() -> void:
	var parent = get_parent()
	var script: Script = parent.get_script()
	if not script:
		return
		
	var source = script.source_code
	if source.is_empty():
		return
		
	if "# INSTRUMENTED_FOR_COVERAGE" in source:
		_register_existing_functions(script)
		return

	var lines = source.split("\n")
	var new_lines = PackedStringArray()
	var functions = []
	
	new_lines.append("# INSTRUMENTED_FOR_COVERAGE")
	
	var i = 0
	while i < lines.size():
		var line = lines[i]
		new_lines.append(line)
		
		var trimmed = line.strip_edges()
		if trimmed.begins_with("func "):
			var func_name_part = trimmed.substr(5).strip_edges()
			var paren_idx = func_name_part.find("(")
			if paren_idx != -1:
				var func_name = func_name_part.substr(0, paren_idx).strip_edges()
				functions.append(func_name)
				
				var indent = ""
				for c in line:
					if c == "\t" or c == " ":
						indent += c
					else:
						break
				indent += "\t"
				
				var injection = indent + "if typeof(self) == TYPE_OBJECT and self.has_method(\"get_script\") and Engine.get_main_loop() and Engine.get_main_loop().root.has_node(\"PluginAutoload\"):\n" + indent + "\tEngine.get_main_loop().root.get_node(\"PluginAutoload\").mark_function_executed(self, \"%s\")" % func_name
				
				# If function signature spans multiple lines, advance until ':'
				while not line.strip_edges().split("#")[0].strip_edges().ends_with(":") and i + 1 < lines.size():
					i += 1
					line = lines[i]
					new_lines.append(line)
				
				new_lines.append(injection)
		i += 1
		
	var scene_name = get_tree().current_scene.name if get_tree().current_scene else "UnknownScene"
	var autoload = _get_autoload()
	if autoload:
		autoload.register_script_functions(scene_name, script.resource_path, functions)
	
	var new_source = "\n".join(new_lines)
	script.source_code = new_source
	script.reload(true)

func _register_existing_functions(script: Script) -> void:
	var source = script.source_code
	var lines = source.split("\n")
	var functions = []
	for line in lines:
		var trimmed = line.strip_edges()
		if trimmed.begins_with("func "):
			var func_name_part = trimmed.substr(5).strip_edges()
			var paren_idx = func_name_part.find("(")
			if paren_idx != -1:
				var func_name = func_name_part.substr(0, paren_idx).strip_edges()
				functions.append(func_name)
				
	var scene_name = get_tree().current_scene.name if get_tree().current_scene else "UnknownScene"
	var autoload = _get_autoload()
	if autoload:
		autoload.register_script_functions(scene_name, script.resource_path, functions)
