extends SceneTree
func _init():
    var timer = Timer.new()
    timer.wait_time = 2.0
    timer.one_shot = true
    timer.timeout.connect(self.quit)
    root.add_child(timer)
    timer.start()
