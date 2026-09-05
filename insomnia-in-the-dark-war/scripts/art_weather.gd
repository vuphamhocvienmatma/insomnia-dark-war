extends Node2D

var weather_type: String = "sunny"
var _time: float = 0.0

# Particles
var _raindrops: Array[Dictionary] = []
var _snowflakes: Array[Dictionary] = []
var _dust: Array[Dictionary] = []
var _fog_layers: Array[Dictionary] = []
var _meteors: Array[Dictionary] = []
var _splashes: Array[Dictionary] = []

# Window Raindrops (Environmental)
var _window_drops: Array[Dictionary] = []

# Lightning
var _lightning_timer: float = 0.0
var _lightning_flash: float = 0.0

# Post Process
var pp_rect: ColorRect
var pp_mat: ShaderMaterial

# Lantern Sway
var _lantern_angle: float = 0.0

func _ready() -> void:
	z_index = -6
	
	pp_rect = ColorRect.new()
	pp_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	pp_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var shader = load("res://shaders/weather_post_process.gdshader")
	if shader:
		pp_mat = ShaderMaterial.new()
		pp_mat.shader = shader
		pp_rect.material = pp_mat
	
	var canvas = CanvasLayer.new()
	canvas.layer = 90
	canvas.add_child(pp_rect)
	add_child(canvas)
	
	# Pre-allocate particle pools
	for i in 150: _raindrops.append({"x": 0.0, "y": 0.0, "speed": 0.0, "length": 0.0, "alpha": 0.0})
	for i in 150: _snowflakes.append({"x": 0.0, "y": 0.0, "speed": 0.0, "drift": 0.0, "phase": 0.0})
	for i in 15: _dust.append({"x": 0.0, "y": 0.0, "speed": 0.0, "phase": 0.0})
	for i in 15: _window_drops.append({"x": 0.0, "y": 0.0, "speed": 0.0})
	
	# 3 fog layers
	_fog_layers = [{"x": 0.0, "speed": 10.0, "alpha": 0.3}, {"x": 0.0, "speed": 20.0, "alpha": 0.2}, {"x": 0.0, "speed": 35.0, "alpha": 0.15}]

	_reset_particles()
	
	var tm = get_tree().get_first_node_in_group("time_manager")
	if tm != null:
		if tm.has_signal("phase_changed"):
			tm.phase_changed.connect(_on_phase_changed)
			
	visible = true # Always visible for post-processing

func set_weather(w_type: String) -> void:
	weather_type = w_type
	_reset_particles()
	_apply_post_process()

func _reset_particles() -> void:
	if weather_type == "sunny":
		for d in _dust:
			d.x = randf_range(-1000, 1000)
			d.y = randf_range(-600, 0)
			d.speed = randf_range(5.0, 10.0)
			d.phase = randf_range(0.0, TAU)
	elif weather_type == "drizzle":
		for i in 50:
			var d = _raindrops[i]
			d.x = randf_range(-1300, 1300)
			d.y = randf_range(-600, 50)
			d.speed = randf_range(200.0, 300.0)
			d.length = randf_range(5.0, 10.0)
			d.alpha = randf_range(0.2, 0.3)
		for w in _window_drops:
			w.x = randf_range(-100, 100) # Cabin window x range approx
			w.y = randf_range(-150, -50)
			w.speed = randf_range(10.0, 30.0)
	elif weather_type == "heavy_rain":
		for i in 150:
			var d = _raindrops[i]
			d.x = randf_range(-1500, 1500)
			d.y = randf_range(-600, 50)
			d.speed = randf_range(500.0, 700.0)
			d.length = randf_range(15.0, 25.0)
			d.alpha = randf_range(0.4, 0.7)
	elif weather_type == "snowstorm":
		for i in 150:
			var s = _snowflakes[i]
			s.x = randf_range(-1500, 1500)
			s.y = randf_range(-600, 50)
			s.speed = randf_range(100.0, 200.0)
			s.drift = randf_range(20.0, 50.0)
			s.phase = randf_range(0.0, TAU)

func _apply_post_process() -> void:
	if not pp_mat: return
	# Sunny,+0.15 vàng,0.1,0.05,0.0
	# Drizzle,-0.05 xanh,0.2,0.1,0.5
	# Storm,-0.1 xanh đậm,0.35,0.2,1.5
	# Fog,-0.05 xám,0.4,0.15,0.5
	# Snow,-0.2 xanh lạnh,0.25,0.1,0.5
	# Meteor,+0.05 tím,0.15,0.05,0.0
	var t_c = Color(1.0, 1.0, 1.0)
	var t_a = 0.0
	var v_i = 0.0
	var g_a = 0.0
	var a_a = 0.0
	
	if weather_type == "sunny":
		t_c = Color(1.0, 0.9, 0.7)
		t_a = 0.15
		v_i = 0.1
		g_a = 0.05
		a_a = 0.0
	elif weather_type == "drizzle":
		t_c = Color(0.8, 0.9, 1.0)
		t_a = 0.05
		v_i = 0.2
		g_a = 0.1
		a_a = 0.5
	elif weather_type == "heavy_rain":
		t_c = Color(0.6, 0.7, 0.9)
		t_a = 0.1
		v_i = 0.35
		g_a = 0.2
		a_a = 1.5
	elif weather_type == "thick_fog":
		t_c = Color(0.8, 0.8, 0.8)
		t_a = 0.05
		v_i = 0.4
		g_a = 0.15
		a_a = 0.5
	elif weather_type == "snowstorm":
		t_c = Color(0.7, 0.8, 1.0)
		t_a = 0.2
		v_i = 0.25
		g_a = 0.1
		a_a = 0.5
	elif weather_type == "meteor_shower":
		t_c = Color(0.9, 0.7, 1.0)
		t_a = 0.05
		v_i = 0.15
		g_a = 0.05
		a_a = 0.0
		
	pp_mat.set_shader_parameter("tint_color", t_c)
	pp_mat.set_shader_parameter("tint_amount", t_a)
	pp_mat.set_shader_parameter("vignette_intensity", v_i)
	pp_mat.set_shader_parameter("grain_amount", g_a)
	pp_mat.set_shader_parameter("aberration_amount", a_a)

func _process(delta: float) -> void:
	if not visible or not is_visible_in_tree(): return
	_time += delta
	queue_redraw()
	
	if weather_type == "sunny":
		for d in _dust:
			d.y -= d.speed * delta
			d.x += sin(_time * 0.5 + d.phase) * 10.0 * delta
			if d.y < -600: d.y = 50
	elif weather_type == "drizzle":
		for i in 50:
			var d = _raindrops[i]
			d.y += d.speed * delta
			if d.y > 10.0: d.y = -600; d.x = randf_range(-1300, 1300)
		for w in _window_drops:
			w.y += w.speed * delta
			if w.y > -50: w.y = -150; w.x = randf_range(-100, 100)
	elif weather_type == "heavy_rain":
		for i in 150:
			var d = _raindrops[i]
			d.y += d.speed * delta
			d.x -= d.speed * 0.25 * delta # 15 degree angle approx
			if d.y > 10.0:
				if randf() < 0.2 and _splashes.size() < 40:
					_splashes.append({"x": d.x, "y": randf_range(-2, 8), "rad": 1.0, "alpha": 0.6})
				d.y = -600; d.x = randf_range(-1500, 1500)
		_lightning_timer -= delta
		if _lightning_timer <= 0.0:
			_lightning_flash = 1.0
			_lightning_timer = randf_range(12.0, 25.0)
		if _lightning_flash > 0.0:
			_lightning_flash -= delta * 5.0
	elif weather_type == "thick_fog":
		for f in _fog_layers:
			f.x += f.speed * delta
			if f.x > 2000: f.x = -2000
	elif weather_type == "snowstorm":
		for i in 150:
			var s = _snowflakes[i]
			s.y += s.speed * delta
			s.x += (s.drift + sin(_time * 2.0 + s.phase) * 50.0) * delta
			if s.y > 50.0: s.y = -600; s.x = randf_range(-1500, 1500)
	elif weather_type == "meteor_shower":
		if randf() < 0.01 and _meteors.size() < 5:
			_meteors.append({"x": randf_range(-500, 1500), "y": -600, "speed": randf_range(800, 1200)})
		for i in range(_meteors.size() - 1, -1, -1):
			var m = _meteors[i]
			m.x -= m.speed * delta
			m.y += m.speed * delta
			if m.y > 200: _meteors.remove_at(i)
			
	# Update splashes
	for i in range(_splashes.size() - 1, -1, -1):
		var sp = _splashes[i]
		sp.rad += delta * 15.0
		sp.alpha -= delta * 3.0
		if sp.alpha <= 0.0: _splashes.remove_at(i)

func _draw() -> void:
	if weather_type == "sunny":
		# Sunbeams
		draw_line(Vector2(500, -600), Vector2(-100, 0), Color(1.0, 0.9, 0.5, 0.1), 100.0)
		draw_line(Vector2(700, -600), Vector2(100, 0), Color(1.0, 0.9, 0.5, 0.08), 80.0)
		for d in _dust:
			draw_circle(Vector2(d.x, d.y), 1.5, Color(1.0, 0.9, 0.5, 0.6))
	elif weather_type == "drizzle":
		for i in 50:
			var d = _raindrops[i]
			draw_line(Vector2(d.x, d.y), Vector2(d.x, d.y + d.length), Color(0.7, 0.8, 0.9, d.alpha), 1.0)
		# Window drops
		for w in _window_drops:
			draw_line(Vector2(w.x, w.y), Vector2(w.x, w.y + 4.0), Color(0.8, 0.9, 1.0, 0.5), 1.5)
	elif weather_type == "heavy_rain":
		for i in 150:
			var d = _raindrops[i]
			draw_line(Vector2(d.x, d.y), Vector2(d.x - d.length*0.25, d.y + d.length), Color(0.6, 0.7, 0.9, d.alpha), 1.5)
		for sp in _splashes:
			draw_arc(Vector2(sp.x, sp.y), sp.rad, 0.0, TAU, 8, Color(0.8, 0.9, 1.0, sp.alpha), 1.0)
		if _lightning_flash > 0:
			draw_rect(Rect2(-2000, -1000, 4000, 2000), Color(1, 1, 1, _lightning_flash * 0.75))
	elif weather_type == "thick_fog":
		for f in _fog_layers:
			# draw huge soft circles for fog
			for i in 5:
				draw_circle(Vector2(f.x + i*400 - 1000, -100 + sin(_time+i)*50), 300, Color(0.8,0.8,0.8, f.alpha))
	elif weather_type == "snowstorm":
		draw_rect(Rect2(-2000, 0, 4000, 50), Color(1.0, 1.0, 1.0, 0.3)) # Snow on ground
		for i in 150:
			var s = _snowflakes[i]
			draw_circle(Vector2(s.x, s.y), 2.0, Color(0.9, 0.95, 1.0, 0.8))
	elif weather_type == "meteor_shower":
		for m in _meteors:
			draw_line(Vector2(m.x, m.y), Vector2(m.x + 40, m.y - 40), Color(1.0, 0.9, 0.6, 0.8), 2.0)
			draw_circle(Vector2(m.x, m.y), 3.0, Color(1.0, 1.0, 0.8))

func _on_phase_changed(is_night: bool) -> void:
	pass # Weather persists through day/night in this version, handled by level_setup
