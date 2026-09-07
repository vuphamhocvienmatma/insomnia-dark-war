extends Node2D

var weather_type: String = "sunny"
var _time: float = 0.0

# Post Process
var pp_rect: ColorRect
var pp_mat: ShaderMaterial

var cabin_world_pos = Vector2(0, -50)
var particle_group: CanvasGroup

# Particle Nodes
var p_rain_far: CPUParticles2D
var p_rain_mid: CPUParticles2D
var p_rain_near: CPUParticles2D

var p_sand_far: CPUParticles2D
var p_sand_mid: CPUParticles2D
var p_sand_near: CPUParticles2D

var p_dust: CPUParticles2D

var _lightning_timer: float = 0.0
var _lightning_flash: float = 0.0
var flash_rect: ColorRect

func _ready() -> void:
	z_index = 10
	
	particle_group = CanvasGroup.new()
	add_child(particle_group)
	
	# Apply mask shader to particle group
	var mask_shader = ShaderMaterial.new()
	mask_shader.shader = load("res://shaders/particle_mask.gdshader")
	particle_group.material = mask_shader
	
	_create_particles()
	
	# PP Rect
	pp_rect = ColorRect.new()
	pp_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	pp_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader = load("res://shaders/weather_post_process.gdshader")
	if shader:
		pp_mat = ShaderMaterial.new()
		pp_mat.shader = shader
		pp_rect.material = pp_mat
		
	var cl = CanvasLayer.new()
	cl.layer = 10
	add_child(cl)
	cl.add_child(pp_rect)
	
	flash_rect = ColorRect.new()
	flash_rect.color = Color(0.4, 0.2, 0.8, 0.0)
	flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	cl.add_child(flash_rect)

func _create_particles() -> void:
	# Rain Near
	p_rain_near = CPUParticles2D.new()
	p_rain_near.amount = 100
	p_rain_near.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p_rain_near.emission_rect_extents = Vector2(2000, 1)
	p_rain_near.position = Vector2(0, -800)
	p_rain_near.direction = Vector2(-0.25, 1.0)
	p_rain_near.spread = 0.0
	p_rain_near.gravity = Vector2(0, 0)
	p_rain_near.initial_velocity_min = 700.0
	p_rain_near.initial_velocity_max = 900.0
	p_rain_near.lifetime = 2.0
	p_rain_near.color = Color(0.6, 0.7, 0.9, 0.6)
	p_rain_near.scale_amount_min = 2.0
	p_rain_near.scale_amount_max = 2.0
	var tex = _create_line_texture(Vector2(0,0), Vector2(-5, 20))
	p_rain_near.texture = tex
	particle_group.add_child(p_rain_near)
	
	p_rain_mid = p_rain_near.duplicate()
	p_rain_mid.amount = 80
	p_rain_mid.initial_velocity_min = 500.0
	p_rain_mid.initial_velocity_max = 600.0
	p_rain_mid.color = Color(0.6, 0.7, 0.9, 0.45)
	p_rain_mid.texture = _create_line_texture(Vector2(0,0), Vector2(-3, 12))
	particle_group.add_child(p_rain_mid)
	
	p_rain_far = p_rain_near.duplicate()
	p_rain_far.amount = 70
	p_rain_far.initial_velocity_min = 300.0
	p_rain_far.initial_velocity_max = 400.0
	p_rain_far.color = Color(0.6, 0.7, 0.9, 0.25)
	p_rain_far.texture = _create_line_texture(Vector2(0,0), Vector2(-2, 8))
	particle_group.add_child(p_rain_far)
	
	# Sand
	p_sand_near = CPUParticles2D.new()
	p_sand_near.amount = 100
	p_sand_near.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p_sand_near.emission_rect_extents = Vector2(1, 600)
	p_sand_near.position = Vector2(-2000, -300)
	p_sand_near.direction = Vector2(1.0, 0.05)
	p_sand_near.spread = 5.0
	p_sand_near.gravity = Vector2(0, 0)
	p_sand_near.initial_velocity_min = 1000.0
	p_sand_near.initial_velocity_max = 1300.0
	p_sand_near.lifetime = 4.0
	p_sand_near.color = Color(0.9, 0.7, 0.5, 0.6)
	p_sand_near.texture = _create_line_texture(Vector2(0,0), Vector2(30, 2))
	particle_group.add_child(p_sand_near)
	
	p_sand_mid = p_sand_near.duplicate()
	p_sand_mid.initial_velocity_min = 700.0
	p_sand_mid.initial_velocity_max = 900.0
	p_sand_mid.color = Color(0.9, 0.7, 0.5, 0.5)
	p_sand_mid.texture = _create_line_texture(Vector2(0,0), Vector2(20, 1))
	particle_group.add_child(p_sand_mid)
	
	p_sand_far = p_sand_near.duplicate()
	p_sand_far.initial_velocity_min = 400.0
	p_sand_far.initial_velocity_max = 600.0
	p_sand_far.color = Color(0.9, 0.7, 0.5, 0.8) # Far haze is thick
	p_sand_far.texture = _create_line_texture(Vector2(0,0), Vector2(10, 1))
	particle_group.add_child(p_sand_far)
	
	# Dust
	p_dust = CPUParticles2D.new()
	p_dust.amount = 50
	p_dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p_dust.emission_rect_extents = Vector2(1500, 600)
	p_dust.position = Vector2(0, -300)
	p_dust.direction = Vector2(0, -1)
	p_dust.gravity = Vector2(0, -10)
	p_dust.initial_velocity_min = 5.0
	p_dust.initial_velocity_max = 10.0
	p_dust.lifetime = 10.0
	p_dust.color = Color(1.0, 0.9, 0.5, 0.6)
	var dt = GradientTexture2D.new()
	dt.width = 3
	dt.height = 3
	dt.fill = GradientTexture2D.FILL_RADIAL
	dt.fill_from = Vector2(0.5, 0.5)
	dt.fill_to = Vector2(1, 1)
	var g = Gradient.new()
	g.set_color(0, Color.WHITE)
	g.set_color(1, Color.TRANSPARENT)
	dt.gradient = g
	p_dust.texture = dt
	particle_group.add_child(p_dust)
	
	_turn_off_all()

func _create_line_texture(start: Vector2, end: Vector2) -> Texture2D:
	var w = int(max(abs(end.x), 1.0))
	var h = int(max(abs(end.y), 1.0))
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 0))
	var is_vertical = h >= w
	for y in h:
		for x in w:
			var t = float(y) / float(max(h - 1, 1)) if is_vertical else float(x) / float(max(w - 1, 1))
			var a = sin(t * PI)
			img.set_pixel(x, y, Color(1, 1, 1, a))
	return ImageTexture.create_from_image(img)

func _turn_off_all() -> void:
	p_rain_near.emitting = false
	p_rain_mid.emitting = false
	p_rain_far.emitting = false
	p_sand_near.emitting = false
	p_sand_mid.emitting = false
	p_sand_far.emitting = false
	p_dust.emitting = false

func set_weather(w_type: String) -> void:
	weather_type = w_type
	_turn_off_all()
	
	if w_type == "sunny":
		p_dust.emitting = true
	elif w_type == "drizzle" or w_type == "heavy_rain":
		p_rain_near.emitting = true
		p_rain_mid.emitting = true
		p_rain_far.emitting = true
	elif w_type == "sandstorm" or w_type == "nightmare_sandstorm":
		p_sand_near.emitting = true
		p_sand_mid.emitting = true
		p_sand_far.emitting = true
		
	if has_node("/root/AudioDirector"):
		AudioDirector.set_weather(w_type)
		# Defer weather BGM crossfade to avoid conflict with phase change BGM
		match w_type:
			"heavy_rain":
				call_deferred("_deferred_weather_bgm", "bgm_rain")
			"sandstorm", "nightmare_sandstorm":
				call_deferred("_deferred_weather_bgm", "bgm_sandstorm")
			"sunny", "drizzle", "thick_fog", "meteor_shower":
				# BGM returns to day/night phase — AudioDirector handles via TimeManager
				pass

	var stove_light = get_tree().get_first_node_in_group("fireplace_light")
	if stove_light == null:
		stove_light = get_tree().root.find_child("StoveLight", true, false)
	if stove_light != null and stove_light.has_method("on_weather_changed"):
		stove_light.on_weather_changed(weather_type)
		
	_apply_post_process()

func _deferred_weather_bgm(track: String) -> void:
	if has_node("/root/AudioDirector"):
		AudioDirector.crossfade_bgm(track, 4.0)

func _apply_post_process() -> void:
	if not pp_mat: return
	var t_c = Color(1.0, 1.0, 1.0)
	var t_a = 0.0
	var v_i = 0.0
	var g_a = 0.0
	var a_a = 0.0
	var desat = 0.0
	var cr_uv = 0.28
	
	if weather_type == "sunny":
		t_c = Color(1.0, 0.9, 0.7)
		t_a = 0.0
		cr_uv = 0.25
	elif weather_type == "drizzle":
		t_c = Color(0.8, 0.9, 1.0)
		t_a = 0.08
		desat = 0.1
		cr_uv = 0.28
	elif weather_type == "heavy_rain":
		t_c = Color(0.65, 0.75, 0.9)
		t_a = 0.12
		desat = 0.12
		v_i = 0.25
		a_a = 0.8
		cr_uv = 0.32
	elif weather_type == "sandstorm":
		t_c = Color(0.88, 0.68, 0.45)
		t_a = 0.28
		desat = 0.20
		v_i = 0.35
		g_a = 0.2
		cr_uv = 0.30
	elif weather_type == "nightmare_sandstorm":
		t_c = Color(0.6, 0.2, 0.3)
		t_a = 0.35
		desat = 0.25
		v_i = 0.45
		a_a = 1.2
		cr_uv = 0.28
		
	pp_mat.set_shader_parameter("tint_color", t_c)
	pp_mat.set_shader_parameter("tint_amount", t_a)
	pp_mat.set_shader_parameter("desaturate_amount", desat)
	pp_mat.set_shader_parameter("vignette_intensity", v_i)
	pp_mat.set_shader_parameter("grain_amount", g_a)
	pp_mat.set_shader_parameter("aberration_amount", a_a)
	pp_mat.set_shader_parameter("clarity_radius_uv", cr_uv)
	
	if particle_group and particle_group.material:
		particle_group.material.set_shader_parameter("clarity_radius_uv", cr_uv)

	# Cozy Thermal Contrast: boost warmth from decoration score
	var cdm: Node = null
	var cdm_list = get_tree().get_nodes_in_group("cabin_decoration_manager")
	if cdm_list.size() > 0:
		cdm = cdm_list[0]
	if cdm == null:
		cdm = get_tree().root.find_child("CabinDecorationManager", true, false)
	if cdm != null and "cozy_score" in cdm:
		var c_score: float = float(cdm.get("cozy_score")) / 120.0
		if pp_mat != null:
			pp_mat.set_shader_parameter("cozy_warmth", c_score * 0.12)

func _get_zoom_factor() -> float:
	var cam = get_viewport().get_camera_2d()
	if cam:
		return clamp((cam.zoom.x - 0.5) / 0.5, 0.0, 1.0)
	return 1.0

func _process(delta: float) -> void:
	if not visible or not is_visible_in_tree(): return
	_time += delta
	
	# Update Shader Cabin Screen Pos
	var cam = get_viewport().get_camera_2d()
	if cam and pp_mat:
		var vp_size = get_viewport().get_visible_rect().size
		var screen_pos = get_viewport().get_canvas_transform() * cabin_world_pos
		var uv = screen_pos / vp_size
		pp_mat.set_shader_parameter("cabin_screen_pos", uv)
		if particle_group and particle_group.material:
			particle_group.material.set_shader_parameter("cabin_screen_pos", uv)
		
	var eco = false
	if has_node("/root/GameState"): eco = get_node("/root/GameState").get("eco_mode")
	
	# Zoom Density Binding
	var zf = _get_zoom_factor()
	var eco_div = 2 if eco else 1
	
	if weather_type == "heavy_rain" or weather_type == "drizzle":
		var base = 100 if weather_type == "heavy_rain" else 30
		p_rain_near.amount = max(1, int(base * lerp(0.4, 1.0, zf)) / eco_div)
		p_rain_mid.amount = max(1, int(base * 0.8 * lerp(0.4, 1.0, zf)) / eco_div)
		p_rain_far.amount = max(1, int(base * 0.7 * lerp(0.4, 1.0, zf)) / eco_div)
		
		if weather_type == "heavy_rain":
			_lightning_timer -= delta
			if _lightning_timer <= 0.0:
				_lightning_flash = 1.0
				_lightning_timer = randf_range(12.0, 25.0)
				if has_node("/root/AudioDirector"):
					AudioDirector.trigger_thunder()
			if _lightning_flash > 0.0:
				_lightning_flash -= delta * 5.0
				flash_rect.color.a = _lightning_flash * 0.3
			else:
				flash_rect.color.a = 0.0
				
	elif weather_type == "sandstorm" or weather_type == "nightmare_sandstorm":
		var base = 100
		p_sand_near.amount = max(1, int(base * lerp(0.3, 1.0, zf)) / eco_div)
		p_sand_mid.amount = max(1, int(base * 0.8 * lerp(0.3, 1.0, zf)) / eco_div)
		p_sand_far.amount = max(1, int(base * 0.7 * lerp(0.3, 1.0, zf)) / eco_div)

	# Beacon Effect
	var is_bad = (weather_type != "sunny" and weather_type != "clear")
	var fireplace = get_tree().get_first_node_in_group("fireplace_light")
	if fireplace:
		var target_e = 1.0
		if is_bad:
			if weather_type == "heavy_rain": target_e = 1.3
			elif weather_type == "sandstorm": target_e = 1.4
			elif weather_type == "nightmare_sandstorm": target_e = 1.5
			target_e += sin(_time * 15.0) * 0.05
		fireplace.set("energy", lerp(float(fireplace.get("energy")), target_e, 0.1))
