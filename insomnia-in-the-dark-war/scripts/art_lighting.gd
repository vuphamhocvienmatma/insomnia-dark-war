extends Node2D

var _time: float = 0.0
var _tm: Node = null

# Fairy lights state
var _fairy_lights: Array[Dictionary] = []
var _dust_motes: Array[Dictionary] = []

func _ready() -> void:
	z_index = 50 # Draw above foreground, inside cabin
	add_to_group("art_lighting")
	
	# Set additive material for lighting effects
	var mat = CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = mat
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 77
	
	for i in 12:
		var lx = lerp(-170.0, 150.0, float(i)/11.0)
		var ly = -140.0 + sin(i*0.8)*5.0
		var col = Color(1.0, 0.8, 0.6) if i%2==0 else Color(1.0, 0.6, 0.8)
		_fairy_lights.append({"x": lx, "y": ly, "phase": rng.randf_range(0, TAU), "color": col})
		
	for i in 25:
		_dust_motes.append({"x": rng.randf_range(-100, 100), "y": rng.randf_range(-100, 0), "phase": rng.randf_range(0, TAU), "speed": rng.randf_range(5.0, 15.0)})

func _process(delta: float) -> void:
	if GameState != null and GameState.eco_mode:
		queue_redraw()
		return
		
	if _tm == null:
		_tm = get_tree().get_first_node_in_group("time_manager")
		
	_time += delta
	
	for d in _dust_motes:
		d.y -= d.speed * delta * 0.5
		d.x += sin(_time + d.phase) * delta * 10.0
		if d.y < -120:
			d.y = 10
			d.x = randf_range(-100, 100)
			
	queue_redraw()

func _draw() -> void:
	var eco = false
	if GameState != null and GameState.eco_mode: eco = true

	# Fireplace
	var fire_alpha = 0.6 + sin(_time * 1.2 * TAU) * 0.15
	if eco: fire_alpha = 0.5
	var fire_pos = Vector2(-80, -35)
	draw_circle(fire_pos, 22.0, Color(1.0, 0.5, 0.1, fire_alpha * 0.8))
	draw_circle(fire_pos, 45.0, Color(1.0, 0.4, 0.05, fire_alpha * 0.25))
	draw_circle(fire_pos, 70.0, Color(1.0, 0.3, 0.0, fire_alpha * 0.08))
	
	if not eco:
		# Fairy Lights
		for fl in _fairy_lights:
			var alpha = 0.4 + sin(_time * 0.5 * TAU + fl.phase) * 0.3
			draw_circle(Vector2(fl.x, fl.y), 15.0, Color(fl.color.r, fl.color.g, fl.color.b, alpha * 0.5))
			draw_circle(Vector2(fl.x, fl.y), 5.0, Color(fl.color.r, fl.color.g, fl.color.b, alpha))
			
		# God Rays & Dust (Only Daytime & Sunny)
		var is_night = true
		var sun_angle = Vector2.ZERO
		var shadow_int = 0.0
		if _tm != null:
			is_night = bool(_tm.get("is_night"))
			sun_angle = _tm.get("sun_angle")
			shadow_int = float(_tm.get("shadow_intensity"))
			
		if not is_night and shadow_int > 0.2:
			var win_center = Vector2(0, -90)
			var ray_dir = -sun_angle.normalized()
			var ray_pts = PackedVector2Array([
				win_center + Vector2(-50, -20),
				win_center + Vector2(50, -20),
				win_center + Vector2(50, -20) + ray_dir * 300.0,
				win_center + Vector2(-50, -20) + ray_dir * 300.0
			])
			var ray_col = Color(1.0, 0.9, 0.7, shadow_int * 0.15)
			draw_colored_polygon(ray_pts, ray_col)
			
			for d in _dust_motes:
				var alpha = 0.2 + sin(_time*2.0 + d.phase) * 0.2
				draw_circle(Vector2(d.x, d.y), 1.0, Color(1.0, 0.9, 0.7, alpha * shadow_int))
