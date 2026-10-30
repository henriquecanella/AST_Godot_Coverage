extends SceneTree

enum CoverageTypes { PLAYER, ENEMY, COLLECTABLE, NPC, INTERACTABLE, HAZARD }

func _init():
    var T_c: Dictionary = {}
    for type in CoverageTypes.values():
        T_c[type] = 0
    print(T_c)
    
    # Try out of bounds on dictionary
    var error = false
    # print(T_c["PLAYER"]) # This would throw key not found probably? Let's check with get index
    
    print("Test passed")
    quit()
