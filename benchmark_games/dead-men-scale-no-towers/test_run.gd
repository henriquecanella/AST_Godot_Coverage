extends SceneTree

func _init():
    var timer = Timer.new()
    timer.wait_time = 1.0
    timer.autostart = true
    timer.connect("timeout", Callable(self, "quit"))
    root.add_child(timer)
