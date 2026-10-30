import os
import re

CATEGORY_MAP = {
    "PLAYER": 0,
    "ENEMY": 1,
    "COLLECTABLE": 2,
    "NPC": 3,
    "INTERACTABLE": 4,
    "HAZARD": 5,
    "OTHER": 6
}

# Directories to search
search_dir = "."

# Find all .tscn and .gd files, excluding addons/
tscn_files = []
gd_files = []

for root, _, files in os.walk(search_dir):
    if "addons/" in root or "/addons" in root or root.startswith("./addons"):
        continue
    for f in files:
        if f.endswith(".tscn"):
            tscn_files.append(os.path.join(root, f))
        elif f.endswith(".gd"):
            gd_files.append(os.path.join(root, f))

# We'll map gd file to its tscn file if they share the same base name in the same dir.
pairs = {}
for gd in gd_files:
    base = gd[:-3]
    tscn = base + ".tscn"
    pairs[gd] = {"gd": gd, "tscn": tscn if tscn in tscn_files else None}

for tscn in tscn_files:
    base = tscn[:-5]
    gd = base + ".gd"
    if gd not in gd_files:
        pairs[tscn] = {"gd": None, "tscn": tscn}

def determine_category(gd_path, content):
    if gd_path is None:
        return "OTHER"
    
    name = os.path.basename(gd_path).lower()
    
    if "player.gd" in name:
        return "PLAYER"
    if "guard.gd" in name or "security_camera.gd" in name:
        return "ENEMY"
    if "treasure.gd" in name:
        return "COLLECTABLE"
    if "dialogue_trigger.gd" in name:
        return "NPC"
    if name in ["computer.gd", "desk.gd", "door.gd", "lift.gd", "light_toggle.gd", "searchable.gd"]:
        return "INTERACTABLE"
    
    # Heuristics based on content
    if "Input." in content or "CharacterBody" in content and "player" in name:
        return "PLAYER"
    if "take_damage" in content or "attack" in content and "enemy" in name:
        return "ENEMY"
    
    return "OTHER"

def inject_trackable_to_tscn(tscn_path, category, object_id):
    with open(tscn_path, "r") as f:
        content = f.read()

    if "[node name=\"Trackable\"" in content:
        return False # Already instrumented

    # Find where to put ext_resource
    lines = content.split("\n")
    ext_resource_index = 0
    max_ext_id = 0
    for i, line in enumerate(lines):
        if line.startswith("[ext_resource"):
            ext_resource_index = i
            match = re.search(r'id="([^"]+)"', line)
            if match:
                id_str = match.group(1)
                # Just keep track if we need a unique id
        elif line.startswith("[node"):
            if ext_resource_index == 0:
                ext_resource_index = i - 1
            break
            
    trackable_id = "trackable_script"
    # Ensure it's unique, but simple trackable_script is usually fine unless collision
    count = 1
    while f'id="{trackable_id}"' in content:
        trackable_id = f"trackable_script_{count}"
        count += 1

    ext_resource_str = f'[ext_resource type="Script" path="res://addons/godot_coverage_metrics/trackable.gd" id="{trackable_id}"]'
    
    # insert after the last ext_resource or at the end of load steps
    # actually, better to insert right before the first [node]
    node_idx = -1
    for i, line in enumerate(lines):
        if line.startswith("[node "):
            node_idx = i
            break
            
    if node_idx != -1:
        lines.insert(node_idx, ext_resource_str)
    else:
        lines.append(ext_resource_str)
        
    # Append the node to the root
    # Wait, the node should be appended at the end of the file or as child of the root node
    # Since we want it as child of root, and root is the first [node] defined. 
    # Godot tscn files define nodes in order. Appending at the end means it's a child of the root by default if parent="."
    
    cat_int = CATEGORY_MAP[category]
    
    trackable_node_str = f"""
[node name="Trackable" type="Node" parent="."]
script = ExtResource("{trackable_id}")
object_id = "{object_id}"
object_type = {cat_int}
"""
    lines.append(trackable_node_str.strip())
    
    with open(tscn_path, "w") as f:
        f.write("\n".join(lines))
    return True

def inject_trackable_to_gd(gd_path, category, content):
    if "has_node(\"Trackable\")" in content:
        return content # Already instrumented
        
    lines = content.split("\n")
    
    inject_str = '\tif has_node("Trackable"):\n\t\t$Trackable.setup_coverage()'
    
    injected = False
    
    if category == "PLAYER":
        for i, line in enumerate(lines):
            if "func catch() -> void:" in line:
                lines.insert(i+1, inject_str)
                injected = True
                break
    elif category == "ENEMY":
        for i, line in enumerate(lines):
            if "get_player().catch()" in line:
                # indent match
                indent = line.split("get_player()")[0]
                lines.insert(i+1, indent + 'if has_node("Trackable"):\n' + indent + '\t$Trackable.setup_coverage()')
                injected = True
                break
        if not injected:
            for i, line in enumerate(lines):
                if "func catch() -> void:" in line:
                    lines.insert(i+1, inject_str)
                    injected = True
                    break
    elif category == "COLLECTABLE":
        for i, line in enumerate(lines):
            if "func steal() -> void:" in line:
                lines.insert(i+1, inject_str)
                injected = True
                break
    elif category == "INTERACTABLE":
        for i, line in enumerate(lines):
            if "func open() -> void:" in line or "func interact() -> void:" in line or "func search() -> void:" in line:
                lines.insert(i+1, inject_str)
                injected = True
                break
        if not injected and "var hacked : bool" in content:
            # handle computer.gd
            for i, line in enumerate(lines):
                if line.startswith("var hacked : bool"):
                    lines[i] = "var hacked : bool = false:\n\tset(val):\n\t\thacked = val\n\t\tif hacked and has_node(\"Trackable\"):\n\t\t\t$Trackable.setup_coverage()"
                    injected = True
                    break
    elif category == "NPC":
        for i, line in enumerate(lines):
            if "func interact() -> void:" in line or "func trigger" in line:
                lines.insert(i+1, inject_str)
                injected = True
                break

    if not injected:
        # Fallback to _ready()
        ready_idx = -1
        for i, line in enumerate(lines):
            if line.startswith("func _ready()"):
                ready_idx = i
                break
        if ready_idx != -1:
            lines.insert(ready_idx+1, inject_str)
            injected = True
        else:
            lines.append("\nfunc _ready() -> void:\n" + inject_str)
            injected = True

    return "\n".join(lines)


modified_files = []

for key, pair in pairs.items():
    gd_path = pair["gd"]
    tscn_path = pair["tscn"]
    
    if gd_path:
        with open(gd_path, "r") as f:
            gd_content = f.read()
    else:
        gd_content = ""
        
    category = determine_category(gd_path, gd_content)
    
    # only instrument if there's a tscn, or if we strictly need to.
    if tscn_path:
        obj_id = os.path.basename(tscn_path).replace(".tscn", "").lower()
        if inject_trackable_to_tscn(tscn_path, category, obj_id):
            modified_files.append((tscn_path, category))
            
    if gd_path:
        new_gd_content = inject_trackable_to_gd(gd_path, category, gd_content)
        if new_gd_content != gd_content:
            with open(gd_path, "w") as f:
                f.write(new_gd_content)
            modified_files.append((gd_path, category))

print("MODIFICATIONS:")
for f, c in modified_files:
    print(f"{f} -> {c}")
