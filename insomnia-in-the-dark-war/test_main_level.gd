extends SceneTree
func _init():
    var scene = load("res://scenes/main_level.tscn")
    if scene:
        print("Loaded successfully")
    else:
        print("Failed to load")
    quit()
