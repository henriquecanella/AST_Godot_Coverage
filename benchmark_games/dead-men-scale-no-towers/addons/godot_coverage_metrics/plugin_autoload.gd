extends Node

enum CoverageTypes {
	PLAYER,
	ENEMY,
	COLLECTABLE,
	NPC,
	INTERACTABLE,
	HAZARD
}

# --- Gameplay Coverage State ---
# Dicts of form: type -> count
var T_c: Dictionary = {}
var I_c: Dictionary = {}

# Dicts of form: scene_name -> { type -> count }
var T_c_S: Dictionary = {}
var I_c_S: Dictionary = {}

# Tracked entities to avoid duplicate counts (as per paper: "each Trackable contributes only once")
var tracked_entities: Dictionary = {} # { instance_key: { type: type, interacted: bool, scene: scene_name } }

# --- Function Coverage State ---
# script_path -> Array of func_names
var script_functions: Dictionary = {} 

# script_path -> Dict of { func_name -> bool }
var executed_functions: Dictionary = {}

# scene_name -> Dict of { script_path -> Dict of { func_name -> bool } }
var executed_functions_scene: Dictionary = {}
var script_functions_scene: Dictionary = {}

func _init() -> void:
	for type in CoverageTypes.values():
		T_c[type] = 0
		I_c[type] = 0

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F12:
		generate_json_report()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		generate_json_report()

# -----------------------------------
# Gameplay Coverage Logic
# -----------------------------------
func register_node(id: String, type: CoverageTypes, path: String, scene_name: String) -> String:
	var instance_key = id + "::" + path
	
	if tracked_entities.has(instance_key):
		return instance_key
		
	tracked_entities[instance_key] = {
		"id": id,
		"type": type,
		"interacted": false,
		"scene": scene_name
	}
	
	T_c[type] += 1
	
	if not T_c_S.has(scene_name):
		T_c_S[scene_name] = {}
		I_c_S[scene_name] = {}
	
	if not T_c_S[scene_name].has(type):
		T_c_S[scene_name][type] = 0
		I_c_S[scene_name][type] = 0
		
	T_c_S[scene_name][type] += 1
	
	return instance_key

func mark_interacted(key: String) -> void:
	if not tracked_entities.has(key):
		return
		
	if tracked_entities[key].interacted:
		return
		
	tracked_entities[key].interacted = true
	var type = tracked_entities[key].type
	var scene_name = tracked_entities[key].scene
	
	I_c[type] += 1
	I_c_S[scene_name][type] += 1

# -----------------------------------
# Function Coverage Logic
# -----------------------------------
func register_script_functions(scene_name: String, script_path: String, functions: Array) -> void:
	if not script_functions.has(script_path):
		script_functions[script_path] = functions
		executed_functions[script_path] = {}
		for f in functions:
			executed_functions[script_path][f] = false
			
	if not script_functions_scene.has(scene_name):
		script_functions_scene[scene_name] = {}
		executed_functions_scene[scene_name] = {}
		
	if not script_functions_scene[scene_name].has(script_path):
		script_functions_scene[scene_name][script_path] = functions
		executed_functions_scene[scene_name][script_path] = {}
		for f in functions:
			executed_functions_scene[scene_name][script_path][f] = false

func mark_function_executed(obj: Object, func_name: String) -> void:
	var script = obj.get_script()
	if not script:
		return
	var script_path = script.resource_path
	
	var scene_name = "UnknownScene"
	if obj is Node and obj.is_inside_tree() and obj.get_tree().current_scene:
		scene_name = obj.get_tree().current_scene.name
		
	if executed_functions.has(script_path):
		executed_functions[script_path][func_name] = true
	
	if executed_functions_scene.has(scene_name):
		if executed_functions_scene[scene_name].has(script_path):
			executed_functions_scene[scene_name][script_path][func_name] = true

# -----------------------------------
# Report Generation
# -----------------------------------
func generate_json_report() -> void:
	if name != "PluginAutoload": return
	var report = {
		"overall_gameplay_coverage": _calculate_overall_gameplay_coverage(),
		"category_gameplay_coverage": _calculate_category_coverage(),
		"scene_category_gameplay_coverage": _calculate_scene_category_coverage(),
		"overall_function_coverage": _calculate_overall_function_coverage(),
		"scene_function_coverage": _calculate_scene_function_coverage(),
		"detailed_entities": _generate_entities_list()
	}
	
	var json_string = JSON.stringify(report, "\t")
	var file = FileAccess.open("res://coverage_report.json", FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("GodotCoverageMetrics: Report saved to res://coverage_report.json")
	else:
		printerr("GodotCoverageMetrics: Failed to save coverage report.")

func _calculate_overall_gameplay_coverage() -> float:
	var total = 0.0
	var interacted = 0.0
	for type in CoverageTypes.values():
		total += float(T_c[type])
		interacted += float(I_c[type])
		
	if total == 0.0: return 0.0
	return (interacted / total) * 100.0

func _calculate_category_coverage() -> Dictionary:
	var coverage = {}
	for type_key in CoverageTypes.keys():
		var type_val = CoverageTypes[type_key]
		var total = float(T_c[type_val])
		var interacted = float(I_c[type_val])
		
		if total == 0.0:
			coverage[type_key] = 0.0
		else:
			coverage[type_key] = (interacted / total) * 100.0
	return coverage
	
func _calculate_scene_category_coverage() -> Dictionary:
	var coverage = {}
	for scene_name in T_c_S.keys():
		coverage[scene_name] = {}
		for type_key in CoverageTypes.keys():
			var type_val = CoverageTypes[type_key]
			if not T_c_S[scene_name].has(type_val):
				continue
				
			var total = float(T_c_S[scene_name][type_val])
			var interacted = float(I_c_S[scene_name][type_val])
			
			if total == 0.0:
				coverage[scene_name][type_key] = 0.0
			else:
				coverage[scene_name][type_key] = (interacted / total) * 100.0
	return coverage

func _calculate_overall_function_coverage() -> float:
	var total_funcs = 0.0
	var executed_funcs = 0.0
	
	for script_path in script_functions.keys():
		var funcs = script_functions[script_path]
		total_funcs += float(funcs.size())
		for f in funcs:
			if executed_functions[script_path][f]:
				executed_funcs += 1.0
				
	if total_funcs == 0.0: return 0.0
	return (executed_funcs / total_funcs) * 100.0
	
func _calculate_scene_function_coverage() -> Dictionary:
	var coverage = {}
	for scene in script_functions_scene.keys():
		var total_funcs = 0.0
		var executed_funcs = 0.0
		for script_path in script_functions_scene[scene].keys():
			var funcs = script_functions_scene[scene][script_path]
			total_funcs += float(funcs.size())
			for f in funcs:
				if executed_functions_scene[scene][script_path][f]:
					executed_funcs += 1.0
		
		if total_funcs == 0.0:
			coverage[scene] = 0.0
		else:
			coverage[scene] = (executed_funcs / total_funcs) * 100.0
	return coverage

func _generate_entities_list() -> Dictionary:
	var covered = []
	var uncovered = []
	
	for key in tracked_entities.keys():
		var entity = tracked_entities[key]
		var entity_info = {
			"id": entity.id,
			"scene": entity.scene,
			"type": CoverageTypes.keys()[entity.type]
		}
		if entity.interacted:
			covered.append(entity_info)
		else:
			uncovered.append(entity_info)
			
	return {
		"covered": covered,
		"uncovered": uncovered
	}
