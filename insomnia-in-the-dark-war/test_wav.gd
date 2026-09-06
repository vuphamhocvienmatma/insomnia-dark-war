extends SceneTree

func _init() -> void:
    var stream = ResourceLoader.load("res://assets/bgm/day_lofi.wav")
    if stream != null:
        print("WAV loaded successfully: ", stream.get_class())
    else:
        print("FAILED to load WAV")
    quit()
