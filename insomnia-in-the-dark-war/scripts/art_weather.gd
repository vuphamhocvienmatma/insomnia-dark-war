extends Node2D

var _raindrops: Array[Dictionary] = []
var _splashes: Array[Dictionary] = []
var _fog_puffs: Array[Dictionary] = []
var _time: float = 0.0


func _ready() -> void:
	z_index = -6
	# 90 raindrops with varying speeds & depths
	for i in 90:
		_raindrops.append({
			"x": randf_range(-1300.0, 1300.0),
			"y": randf_range(-600.0, 50.0),
			"speed": randf_range(350.0, 600.0),
			"length": randf_range(8.0, 18.0),
			"alpha": randf_range(0.25, 0.65)
		})
		
	# Ground fog mist pillows
	for i in 12:
		_fog_puffs.append({
			"x": randf_range(-1200.0, 1200.0),
			"y": randf_range(-25.0, 15.0),
			"w": randf_range(120.0, 240.0),
			"h": randf_range(16.0, 32.0),
			"speed": randf_range(12.0, 25.0),
			"phase": randf_range(0.0, TAU)
		})
		
	visible = false
	var tm = get_tree().get_first_node_in_group("time_manager")
	if tm != null:
		tm.phase_changed.connect(_on_phase_changed)


func _process(delta: float) -> void:
	if not visible:
		return
		
	_time += delta
	
	# Update rain
	for d in _raindrops:
		d["y"] = float(d["y"]) + float(d["speed"]) * delta
		d["x"] = float(d["x"]) - float(d["speed"]) * delta * 0.25
		if float(d["y"]) > 10.0:
			# Chance to trigger splash on ground outside cabin
			var rx: float = float(d["x"])
			if (rx < -220.0 or rx > 220.0) and randf() < 0.35 and _splashes.size() < 25:
				_splashes.append({
					"x": rx,
					"y": randf_range(-2.0, 8.0),
					"rad": 1.0,
					"max_rad": randf_range(3.0, 6.0),
					"alpha": 0.6
				})
			d["y"] = -600.0
			d["x"] = randf_range(-1300.0, 1300.0)
			
	# Update splashes
	var s_idx: int = _splashes.size() - 1
	while s_idx >= 0:
		var sp: Dictionary = _splashes[s_idx]
		sp["rad"] = float(sp["rad"]) + delta * 14.0
		sp["alpha"] = float(sp["alpha"]) - delta * 2.5
		if float(sp["alpha"]) <= 0.0:
			_splashes.remove_at(s_idx)
		s_idx -= 1
		
	# Update fog puffs
	for f in _fog_puffs:
		f["x"] = float(f["x"]) + float(f["speed"]) * delta
		if float(f["x"]) > 1300.0:
			f["x"] = -1300.0
			
	queue_redraw()


func _draw() -> void:
	# Draw low-lying foggy mist
	for f in _fog_puffs:
		var fx: float = float(f["x"])
		# Don't draw heavy fog inside cabin
		if fx > -180.0 and fx < 180.0:
			continue
		var fy: float = float(f["y"]) + sin(_time + float(f["phase"])) * 4.0
		var fw: float = float(f["w"])
		var fh: float = float(f["h"])
		draw_set_transform(Vector2(fx, fy), 0.0, Vector2(1.0, fh / fw))
		draw_circle(Vector2.ZERO, fw * 0.5, Color(0.65, 0.75, 0.88, 0.06))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Draw diagonal rain streaks
	for d in _raindrops:
		var x: float = float(d["x"])
		var y: float = float(d["y"])
		var len_drop: float = float(d["length"])
		var alpha: float = float(d["alpha"])
		var start: Vector2 = Vector2(x, y)
		var end: Vector2 = Vector2(x - len_drop * 0.25, y + len_drop)
		draw_line(start, end, Color(0.72, 0.85, 0.98, alpha), 1.2)
		
	# Draw ground splash ripples
	for sp in _splashes:
		var sx: float = float(sp["x"])
		var sy: float = float(sp["y"])
		var r: float = float(sp["rad"])
		var a: float = float(sp["alpha"])
		draw_arc(Vector2(sx, sy), r, 0.0, TAU, 10, Color(0.80, 0.90, 1.0, a), 1.0)


func _on_phase_changed(is_night: bool) -> void:
	visible = is_night

