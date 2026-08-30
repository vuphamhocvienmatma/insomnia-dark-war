extends Node2D

var _raindrops: Array[Dictionary] = []


func _ready() -> void:
	z_index = -7
	for i in 50:
		_raindrops.append({
			"x": randf_range(-1300.0, 1300.0),
			"y": randf_range(-800.0, 0.0),
			"speed": randf_range(200.0, 400.0)
		})
	visible = false
	var tm = get_tree().get_first_node_in_group("time_manager")
	if tm != null:
		tm.phase_changed.connect(_on_phase_changed)


func _process(delta: float) -> void:
	for d in _raindrops:
		d["y"] = float(d["y"]) + float(d["speed"]) * delta
		if float(d["y"]) > 300.0:
			d["y"] = -800.0
			d["x"] = randf_range(-1300.0, 1300.0)
	queue_redraw()


func _draw() -> void:
	for d in _raindrops:
		var x: float = float(d["x"])
		var y: float = float(d["y"])
		draw_line(Vector2(x, y), Vector2(x - 2.0, y + 8.0), Color(0.7, 0.8, 0.9, 0.4), 1.0)


func _on_phase_changed(is_night: bool) -> void:
	visible = is_night
