---
name: godot-coverage-metrics-instrumentation
description: Specialist skill for installing and instrumenting Godot 4.x games with the godot_coverage_metrics plugin (Trackable scene nodes and GDScript interaction calls) to measure gameplay and function coverage.
---

# Godot Coverage Metrics Instrumentation Skill

Use this skill when installing, configuring, and instrumenting the **`godot_coverage_metrics`** plugin in a Godot 4.x project to measure **Gameplay Coverage** (tracked entity interactions across 6 categories and scenes) and **Function Coverage** (executed GDScript functions globally and per scene).

---

## 1. Plugin Architecture & Mechanics

The plugin resides in `res://addons/godot_coverage_metrics/` and operates via two core components:

### 1.1 `PluginAutoload` (`plugin_autoload.gd`)
- Registered as an autoload singleton under `[autoload]` in `project.godot`.
- Maintains global and per-scene dictionaries tracking:
  - **Total Entities ($T_c$, $T_c^S$)**: Registered `Trackable` instances partitioned by category.
  - **Interacted Entities ($I_c$, $I_c^S$)**: Entities whose interaction callback was triggered during gameplay.
  - **Registered Functions**: All functions defined in scripts attached to tracked nodes.
  - **Executed Functions**: Functions invoked during runtime (injected dynamically).
- Serializes coverage results to `res://coverage_report.json` upon pressing **`F12`** or on window close (`NOTIFICATION_WM_CLOSE_REQUEST`).

### 1.2 `Trackable` Node (`trackable.gd`)
- Extends `Node` (`class_name Trackable`, `uid="uid://631jm7xfjvbg"`).
- Key export properties:
  - `object_id: String = ""` (human-readable identifier, e.g. `"player"`, `"goomba"`, `"coin_01"`).
  - `object_type: int = 0` (integer strictly in range `0..5`).
- Runtime behavior:
  - `_ready()`:
    1. Registers parent with `PluginAutoload.register_node(object_id, object_type, get_parent().get_path(), scene_name)` using key `object_id + "::" + str(get_parent().get_path())`.
    2. Calls `call_deferred("_do_setup_coverage")` if parent has a script. This rewrites the parent script in-memory, prepending `PluginAutoload.mark_function_executed(self, "<func_name>")` to every function.
  - `mark_interacted()` (alias: `setup_coverage()`): Marks this entity instance as interacted in `PluginAutoload`.

---

## 2. Category Enum Mapping Guide (`object_type`)

> [!CRITICAL]
> `PluginAutoload.CoverageTypes` only defines keys `0` through `5`. Values of `6` or higher cause a runtime `Invalid get index` crash on `T_c[type] += 1`. All tracked entities **must** use an integer from `0` to `5`.

| `object_type` | Enum Name | Description & Heuristics | Concrete Examples |
| :---: | :--- | :--- | :--- |
| **`0`** | **`PLAYER`** | The playable character(s) and their active movement/ability sub-components. | `Player`, `Character`, `Princess`, `Jon`, `MovementNode`, `DashNode`, `Sprint`, `Head` |
| **`1`** | **`ENEMY`** | Hostile characters, AI entities, turrets, and hostile obstacles. | `Guard`, `SecurityCamera`, `Goomba`, `Bobomb`, `Koopa`, `Thwomp`, `Ant`, `Bat`, `DemonJr` |
| **`2`** | **`COLLECTABLE`** | Items, pickups, and rewards collected by the player. | `Coin`, `Gem`, `Bit`, `Treasure`, `Shine`, `PitonGem`, `HealthPickup`, `Melon` |
| **`3`** | **`NPC`** | Non-hostile interactive characters, rescued entities, and dialogue triggers. | `Fairy`, `Rita`, `Toad`, `DialogueTrigger` |
| **`4`** | **`INTERACTABLE`** | Environment triggers, mechanisms, props, screen/level controllers, tools, and UI menus. | `Door`, `Spring`, `Campfire`, `Piton`, `Rope`, `Lift`, `Computer`, `Desk`, `Searchable`, `Pipe`, `NextScreenGate`, `Gun`, `Bullet`, `HUD`, `PauseMenu`, `TitleScreen`, `WorldController` |
| **`5`** | **`HAZARD`** | Environmental death zones, damaging obstacles, traps, and explosions. | `Killbox`, `Killzone`, `Spikes`, `DeathPlane`, `Hitbox`, `Explosion`, `WaterHazard`, `Tractor` (if hostile/fatal) |

---

## 3. Systematic Instrumentation Workflow

### Step 1: Install & Configure the Plugin
1. Copy `addons/godot_coverage_metrics/` to the Godot project root (directory containing `project.godot`).
2. Update `project.godot`:
   - Under `[autoload]`:
     ```ini
     PluginAutoload="*res://addons/godot_coverage_metrics/plugin_autoload.gd"
     ```
   - Under `[editor_plugins]`:
     ```ini
     enabled=PackedStringArray("res://addons/godot_coverage_metrics/plugin.cfg")
     ```
     *(If `enabled=PackedStringArray(...)` already exists, append `"res://addons/godot_coverage_metrics/plugin.cfg"` to the array).*

### Step 2: Determine Scope & Select Scenes to Instrument
Follow these rules when traversing project scenes:

1. **Root Scripted Scenes**: Every `.tscn` whose root node has an attached `.gd` script should have a `Trackable` child node (`parent="."`).
2. **Component-Based Entities (Scripted Child Nodes)**:
   - Godot games frequently attach distinct logic scripts to child sub-nodes (e.g. `DashNode`, `MovementNode`, `LedgeGrabNode` under `Character`, or `Gun` and `Camera2D` under `Player`).
   - Because `Trackable` only registers its direct parent's script (`get_parent().get_script()`), **add a dedicated `Trackable` child node under each scripted child node**:
     ```ini
     [node name="Trackable" type="Node" parent="StateNode/MovementNode"]
     script = ExtResource("trackable_script")
     object_id = "movement_node"
     object_type = 0
     ```
3. **Inherited Scenes (`.tscn` Inheritance)**:
   - When a scene inherits from a base scene that already has a `Trackable` node (e.g. `coin.tscn` and `gem.tscn` inheriting from `valuable.tscn`, or `pause_menu_singleplayer.tscn` inheriting from `pause_menu.tscn`), **override the `object_id` property** on the inherited node:
     ```ini
     [node name="Trackable" parent="." index="1"]
     object_id = "gem"
     ```
4. **Skip Purely Static, Scriptless Geometry Prefabs**:
   - Do **not** instrument static collision-only `.tscn` files (e.g. scriptless `StaticBody2D` walls, ground tiles, visual props) unless they have an active script or are explicitly interacted with by name in another script.
5. **Full Repository Scope (Secondary Systems)**:
   - In large projects (such as games with embedded level designers, custom tools, or extensive UI trees like `Legacy_SM63Redux`), scan beyond `scenes/levels/` to include scripted UI scenes (`menus/`, `hud/`, `dialogue/`), tools, and cutscenes.

### Step 3: Scene File Injection Syntax (`.tscn`)
1. **ExtResource Declaration**: Place before the first `[sub_resource]` or `[node]` line:
   ```ini
   [ext_resource type="Script" uid="uid://631jm7xfjvbg" path="res://addons/godot_coverage_metrics/trackable.gd" id="trackable_script"]
   ```
   *(If the `[gd_scene load_steps=N ...]` header is present, either increment `N` by 1 or omit `load_steps` so Godot 4 computes it dynamically).*

2. **Trackable Node Block**: Place **before any `[connection ...]` lines** at the end of the node hierarchy:
   ```ini
   [node name="Trackable" type="Node" parent="."]
   script = ExtResource("trackable_script")
   object_id = "coin"
   object_type = 2
   ```

### Step 4: GDScript Interaction Calls (`.gd`)

1. **Favor Exactly One Canonical Call per Script**:
   - Human instrumentation strongly favors **1 clean interaction call per script** placed at the primary interaction event, rather than scattering duplicate calls across every input check.
2. **Canonical Placement Rules**:
   - **`COLLECTABLE (2)`**: Inside the collection method (`collect()`, `steal()`, `pickup()`, `_on_body_entered()`) **before** `queue_free()`.
   - **`INTERACTABLE (4)`**:
     - *Physical mechanisms (doors, springs, levers, spawn points)*: Inside `open()`, `bounce()`, `interact()`, `set_spawn()`.
     - *Screens / Menus (`TitleScreen`, `PauseMenu`, `EndScreen`)*: Inside `_on_button_pressed()`, `pause()`, or `_on_timeout()`.
     - *Level / World / HUD Controllers*: Inside `collect_coin()`, `_on_door_entered()`, or in `_ready()`.
   - **`ENEMY (1)`**: Inside `destroy()`, `enemy_die()`, or when detecting/damaging the player (`_on_jumpzone_body_entered()`).
   - **`HAZARD (5)`**: Inside `kill_player()`, `_on_area_entered()`, or collision damage handlers.
   - **`PLAYER (0)`**: Inside primary movement/jump physics processing or `apply_damage()` / `die()`.
3. **Safe Node Lookup Guard**:
   Always guard the call to prevent null reference errors if instantiated dynamically or shared across scenes:
   ```gdscript
   if has_node("Trackable"):
   	$Trackable.mark_interacted()
   ```
4. **Collision-Based Propagation (Passive Targets)**:
   When the player collides with an interactable or hazard that lacks an active trigger script:
   ```gdscript
   var collision = get_last_slide_collision()
   if collision:
   	var collider = collision.get_collider()
   	if collider and collider.has_node("Trackable"):
   		collider.get_node("Trackable").mark_interacted()
   ```

---

## 4. UI Child Iteration Safeguards

> [!WARNING]
> Many Godot UI scripts (menus, option lists, button containers) iterate over `get_children()` and assume every child is a `Control`. Adding a `Trackable` (`Node`) child causes a runtime crash on property access (e.g. `child.custom_minimum_size`).

**Remedy**:
When instrumenting container scripts that iterate children, add a type guard:
```gdscript
for child in get_children():
	if not child is Control:
		continue
	# ... existing UI logic ...
```
Alternatively, place `Trackable` on the parent node of the container, rather than inside the item container.

---

## 5. Automated Instrumentation Recipe (Python Helper)

When instrumenting a large repository, run this standalone Python automation pattern:

```python
import os, re, shutil

def instrument_project(project_dir, plugin_src="addons/godot_coverage_metrics"):
    # 1. Install Plugin
    dest = os.path.join(project_dir, "addons", "godot_coverage_metrics")
    os.makedirs(dest, exist_ok=True)
    shutil.copytree(plugin_src, dest, dirs_exist_ok=True)

    # 2. Configure project.godot
    pfile = os.path.join(project_dir, "project.godot")
    with open(pfile, "r") as f:
        content = f.read()
    autoload = 'PluginAutoload="*res://addons/godot_coverage_metrics/plugin_autoload.gd"'
    if "PluginAutoload=" not in content:
        content = content.replace("[autoload]\n", f"[autoload]\n\n{autoload}\n", 1) if "[autoload]" in content else content + f"\n\n[autoload]\n\n{autoload}\n"
    cfg = "res://addons/godot_coverage_metrics/plugin.cfg"
    if cfg not in content:
        if "[editor_plugins]" in content:
            content = re.sub(r'enabled=PackedStringArray\(([^)]*)\)', lambda m: f'enabled=PackedStringArray({m.group(1).strip() + ", " if m.group(1).strip() else ""}"{cfg}")', content)
        else:
            content += f'\n\n[editor_plugins]\n\nenabled=PackedStringArray("{cfg}")\n'
    with open(pfile, "w") as f:
        f.write(content)

    # 3. Instrument Scenes and Scripts
    for root, dirs, files in os.walk(project_dir):
        if "addons" in root.split(os.sep) or ".godot" in root.split(os.sep):
            continue
        for fn in files:
            path = os.path.join(root, fn)
            # Handle .tscn injection
            if fn.endswith(".tscn"):
                with open(path, "r") as f:
                    s_txt = f.read()
                if '[node name="Trackable"' not in s_txt and 'res://addons/godot_coverage_metrics/trackable.gd' not in s_txt:
                    # check if scene has a script on root
                    if 'script = ExtResource(' in s_txt:
                        ext_res = '[ext_resource type="Script" uid="uid://631jm7xfjvbg" path="res://addons/godot_coverage_metrics/trackable.gd" id="trackable_script"]\n'
                        # insert ext_resource before first [node] or [sub_resource]
                        pos = s_txt.find("[node ")
                        sub_pos = s_txt.find("[sub_resource ")
                        if sub_pos != -1 and sub_pos < pos:
                            pos = sub_pos
                        s_txt = s_txt[:pos] + ext_res + s_txt[pos:]
                        
                        # Node definition
                        oid = fn.replace(".tscn", "").lower()
                        cat = 4 # Default INTERACTABLE; customize per entity type
                        if "player" in oid or "character" in oid: cat = 0
                        elif "enemy" in oid or "boss" in oid: cat = 1
                        elif "coin" in oid or "gem" in oid or "pickup" in oid: cat = 2
                        elif "npc" in oid or "fairy" in oid: cat = 3
                        elif "kill" in oid or "hazard" in oid or "spike" in oid: cat = 5

                        node_str = f'\n[node name="Trackable" type="Node" parent="."]\nscript = ExtResource("trackable_script")\nobject_id = "{oid}"\nobject_type = {cat}\n'
                        # Insert before first [connection] or at end
                        conn_pos = s_txt.find("[connection ")
                        if conn_pos != -1:
                            s_txt = s_txt[:conn_pos] + node_str + "\n" + s_txt[conn_pos:]
                        else:
                            s_txt = s_txt.rstrip() + "\n" + node_str
                        with open(path, "w") as f:
                            f.write(s_txt)

            # Handle .gd interaction injection
            elif fn.endswith(".gd"):
                with open(path, "r") as f:
                    g_txt = f.read()
                if "mark_interacted()" not in g_txt and "setup_coverage()" not in g_txt:
                    call_str = '\tif has_node("Trackable"):\n\t\t$Trackable.mark_interacted()\n'
                    # Inject in primary interaction handler or _ready()
                    targets = ["func collect(", "func open(", "func bounce(", "func destroy(", "func die(", "func _ready("]
                    for tgt in targets:
                        idx = g_txt.find(tgt)
                        if idx != -1:
                            line_end = g_txt.find("\n", idx)
                            g_txt = g_txt[:line_end+1] + call_str + g_txt[line_end+1:]
                            with open(path, "w") as f:
                                f.write(g_txt)
                            break
```

---

## 6. Pre-Flight Verification Checklist

Always execute these verification steps before concluding instrumentation:

- [ ] **Plugin Files & Singleton**:
  - `addons/godot_coverage_metrics/{plugin.cfg,plugin.gd,plugin_autoload.gd,trackable.gd}` exist in project root.
  - `project.godot` contains `PluginAutoload` under `[autoload]`.
  - `project.godot` lists `res://addons/godot_coverage_metrics/plugin.cfg` under `[editor_plugins]`.
- [ ] **Scene Validity**:
  - Every `[node name="Trackable" ...]` references `trackable_script` (with UID `uid://631jm7xfjvbg`).
  - All `object_type` attributes are strictly integers in `0..5`.
  - In composite actors, child component scripts have their own `Trackable` child nodes (`parent="<path>"`).
  - All `[node name="Trackable" ...]` blocks are placed **before** any `[connection ...]` lines.
- [ ] **Script Integrity**:
  - Exactly 1 canonical `$Trackable.mark_interacted()` per script at the primary interaction event.
  - Safe lookup guard `if has_node("Trackable"):` is used.
  - Calls occur **before** `queue_free()` or scene transitions.
  - UI child iteration loops have `if not child is Control: continue` guards.
- [ ] **Headless Execution Test**:
  Run Godot headless to confirm syntax, parsing, and execution:
  ```bash
  godot --headless --path <path_to_game> --quit
  ```
  Ensure process exits with code `0` and produces zero script or scene errors.
