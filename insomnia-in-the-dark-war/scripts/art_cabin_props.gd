extends Node2D

const OUTLINE := Color(0.18, 0.14, 0.12, 1.0)
const WOOD_PLANK_A: Color = Color(0.36, 0.25, 0.18, 1.0)
const WOOD_PLANK_B: Color = Color(0.30, 0.20, 0.14, 1.0)
const WOOD_LINE: Color = Color(0.18, 0.12, 0.08, 0.85)
const WOOD_BEAM: Color = Color(0.22, 0.15, 0.10, 1.0)
const SOLAR: Color = Color(0.12, 0.18, 0.36, 1.0)
const SOLAR_LINE: Color = Color(0.35, 0.52, 0.78, 1.0)
const WARM_GLOW: Color = Color(1.0, 0.88, 0.55, 0.9)
const FAIRY_WIRE: Color = Color(0.15, 0.15, 0.15, 0.7)

var _time: float = 0.0
var _clock_str_cache: String = "06:00"
var _solar_pct_cache: float = 0.0
var _clock_timer: float = 0.0
var _badge_cache: Array[bool] = [false, false, false, false, false, false, false]
var _badge_timer: float = 0.0
var _tm: Node = null
var dust_particles: Array[Dictionary] = []
@onready var _font: Font = preload("res://assets/fonts/MainFont.tres")


func _ready() -> void:
	z_index = -3
	for i in 50:
		dust_particles.append({
			"pos": _get_random_sunray_pos(),
			"speed": randf_range(5.0, 15.0),
			"alpha": randf_range(0.1, 0.4)
		})
	_tm = get_tree().get_first_node_in_group("time_manager")

func _get_random_sunray_pos() -> Vector2:
	return Vector2(randf_range(-150.0, 150.0), randf_range(-190.0, 0.0))


func _process(delta: float) -> void:
	_time += delta * 2.5
	_clock_timer += delta
	if _clock_timer > 1.0:
		_clock_timer = 0.0
		_update_clock_cache()

	_badge_timer += delta
	if _badge_timer > 2.0:
		_badge_timer = 0.0
		_update_badge_cache()
	for d in dust_particles:
		d["pos"].y -= d["speed"] * delta
		d["pos"].x += sin(_time + d["speed"]) * 0.2
		if d["pos"].y < -190.0 or randf() < 0.001:
			d["pos"] = _get_random_sunray_pos()
			d["pos"].y = 0.0
	queue_redraw()


func _draw() -> void:
	_draw_ground_window_light_shaft()
	_draw_interior_overlay()
	_draw_wall_planks()
	_draw_diegetic_ui()
	_draw_wooden_badge_wall()
	_draw_custom_decorations()
	_draw_mezzanine_bedding()
	_draw_shelves_and_supplies()
	_draw_steaming_mug()
	_draw_guitar()
	_draw_leather_armchair()
	_draw_workbench_and_tools()
	_draw_gun_rack()
	_draw_turntable()
	_draw_supply_crates()
	_draw_window_curtains()
	_draw_fairy_lights()
	_draw_pitched_roof_and_rooftop_stations()
	_draw_ladder()
	_draw_lantern()


func _draw_wall_planks() -> void:
	# 1. 2.5D Left Perspective Side Wall (Angled fanning forward towards camera)
	var left_wall: PackedVector2Array = PackedVector2Array([
		Vector2(-232.0, -215.0),
		Vector2(-195.0, -195.0),
		Vector2(-195.0, -12.0),
		Vector2(-232.0, 18.0)
	])
	draw_colored_polygon(left_wall, WOOD_PLANK_B * 0.76)
	_draw_polyline_loop(left_wall, OUTLINE)
	# Left perspective wall studs
	for p_idx in 3:
		var t: float = float(p_idx + 1) / 4.0
		var top_pt: Vector2 = Vector2(-232.0, -215.0).lerp(Vector2(-195.0, -195.0), t)
		var bot_pt: Vector2 = Vector2(-232.0, 18.0).lerp(Vector2(-195.0, -12.0), t)
		draw_line(top_pt, bot_pt, WOOD_LINE, 1.5)

	# 2. 2.5D Right Perspective Side Wall (Angled fanning forward towards camera)
	var right_wall: PackedVector2Array = PackedVector2Array([
		Vector2(195.0, -195.0),
		Vector2(232.0, -215.0),
		Vector2(232.0, 18.0),
		Vector2(195.0, -12.0)
	])
	draw_colored_polygon(right_wall, WOOD_PLANK_B * 0.70)
	_draw_polyline_loop(right_wall, OUTLINE)
	# Right perspective wall studs
	for p_idx in 3:
		var t: float = float(p_idx + 1) / 4.0
		var top_pt: Vector2 = Vector2(195.0, -195.0).lerp(Vector2(232.0, -215.0), t)
		var bot_pt: Vector2 = Vector2(195.0, -12.0).lerp(Vector2(232.0, 18.0), t)
		draw_line(top_pt, bot_pt, WOOD_LINE, 1.5)

	# 3. 2.5D Perspective Ceiling Rafters
	var ceiling: PackedVector2Array = PackedVector2Array([
		Vector2(-232.0, -215.0),
		Vector2(232.0, -215.0),
		Vector2(195.0, -195.0),
		Vector2(-195.0, -195.0)
	])
	draw_colored_polygon(ceiling, WOOD_PLANK_B * 0.62)
	_draw_polyline_loop(ceiling, OUTLINE)
	for r_idx in 7:
		var rt: float = float(r_idx + 1) / 8.0
		var f_pt: Vector2 = Vector2(-232.0, -215.0).lerp(Vector2(232.0, -215.0), rt)
		var b_pt: Vector2 = Vector2(-195.0, -195.0).lerp(Vector2(195.0, -195.0), rt)
		draw_line(f_pt, b_pt, WOOD_BEAM, 2.5)

	# 4. 2.5D Back Wall with horizontal wooden planks [-195, 195] x [-195, -12]
	var plank_h: float = 18.0
	var y: float = -195.0
	var i: int = 0
	while y < -12.0:
		var col: Color = WOOD_PLANK_A if (i % 2 == 0) else WOOD_PLANK_B
		draw_rect(Rect2(-195.0, y, 390.0, plank_h), col)
		draw_line(Vector2(-195.0, y), Vector2(195.0, y), WOOD_LINE, 1.2)
		var seam_x: float = -110.0 if (i % 2 == 0) else 70.0
		draw_line(Vector2(seam_x, y), Vector2(seam_x, y + plank_h), WOOD_LINE, 1.0)
		draw_circle(Vector2(seam_x - 6.0, y + plank_h * 0.5), 1.2, OUTLINE)
		draw_circle(Vector2(seam_x + 6.0, y + plank_h * 0.5), 1.2, OUTLINE)
		y += plank_h
		i += 1

	# 5. 2.5D Perspective Ground Floorboards (Fanning forward from y = -12 to y = 18)
	var floor_poly: PackedVector2Array = PackedVector2Array([
		Vector2(-195.0, -12.0),
		Vector2(195.0, -12.0),
		Vector2(228.0, 18.0),
		Vector2(-228.0, 18.0)
	])
	draw_colored_polygon(floor_poly, WOOD_PLANK_A * 0.88)
	_draw_polyline_loop(floor_poly, OUTLINE)

	# Perspective floor plank lines fanning outwards
	for f_idx in 12:
		var ft: float = float(f_idx) / 12.0
		var back_x: float = lerpf(-195.0, 195.0, ft)
		var front_x: float = lerpf(-228.0, 228.0, ft)
		draw_line(Vector2(back_x, -12.0), Vector2(front_x, 18.0), WOOD_LINE, 1.4)

	# 6. Front Cutaway Foundation Timber Beam at y = 18
	var rim_beam: Rect2 = Rect2(-230.0, 18.0, 460.0, 7.0)
	draw_rect(rim_beam, WOOD_BEAM)
	_draw_rect_outline(rim_beam, OUTLINE)
	for bolt_x in [-210.0, -140.0, -70.0, 0.0, 70.0, 140.0, 210.0]:
		draw_circle(Vector2(bolt_x, 21.5), 1.5, Color(0.45, 0.48, 0.52, 1.0))


func _draw_mezzanine_bedding() -> void:
	# 2.5D Mezzanine Loft Floor Surface: depth strip from y = -158 to -140
	var loft_poly: PackedVector2Array = PackedVector2Array([
		Vector2(-195.0, -158.0),
		Vector2(195.0, -158.0),
		Vector2(202.0, -140.0),
		Vector2(-202.0, -140.0)
	])
	draw_colored_polygon(loft_poly, WOOD_PLANK_A * 0.85)
	_draw_polyline_loop(loft_poly, OUTLINE)

	# --- Cutaway Hatchway Opening for Interior Ladder at [136, 164] ---
	var hatch_rect: Rect2 = Rect2(136.0, -158.0, 28.0, 18.0)
	draw_rect(hatch_rect, Color(0.10, 0.07, 0.05, 1.0)) # Dark cutaway depth
	# Hatch timber framing & brass corner brackets
	draw_line(Vector2(136.0, -158.0), Vector2(164.0, -158.0), WOOD_BEAM, 3.0)
	draw_line(Vector2(136.0, -158.0), Vector2(136.0, -140.0), WOOD_BEAM, 3.0)
	draw_line(Vector2(164.0, -158.0), Vector2(164.0, -140.0), WOOD_BEAM, 3.0)
	draw_circle(Vector2(137.5, -156.5), 1.5, Color(0.85, 0.70, 0.30, 1.0))
	draw_circle(Vector2(162.5, -156.5), 1.5, Color(0.85, 0.70, 0.30, 1.0))

	# Front supporting timber beam (with gap for the ladder hatch)
	var left_beam: Rect2 = Rect2(-204.0, -140.0, 340.0, 8.0) # -204 to 136
	draw_rect(left_beam, WOOD_BEAM)
	_draw_rect_outline(left_beam, OUTLINE)
	for b_x in [-180.0, -100.0, -20.0, 60.0, 120.0]:
		draw_circle(Vector2(b_x, -136.0), 1.4, Color(0.45, 0.48, 0.52, 1.0))

	var right_beam: Rect2 = Rect2(164.0, -140.0, 38.0, 8.0) # 164 to 202
	draw_rect(right_beam, WOOD_BEAM)
	_draw_rect_outline(right_beam, OUTLINE)
	draw_circle(Vector2(182.0, -136.0), 1.4, Color(0.45, 0.48, 0.52, 1.0))

	# 2.5D Bed with perspective mattress and fluffy pillow
	draw_circle(Vector2(-150.0, -138.0), 25.0, Color(0.0, 0.0, 0.0, 0.3))
	var mattress: Rect2 = Rect2(-188.0, -154.0, 68.0, 14.0)
	_draw_rounded_rect(mattress, Color(0.24, 0.28, 0.36, 1.0), 3.0)
	_draw_rect_outline(mattress, OUTLINE)
	var quilt: Rect2 = Rect2(-172.0, -153.0, 50.0, 13.0)
	_draw_rounded_rect(quilt, Color(0.72, 0.32, 0.28, 1.0), 3.0)
	_draw_rect_outline(quilt, OUTLINE)
	draw_line(Vector2(-155.0, -153.0), Vector2(-155.0, -140.0), Color(0.90, 0.82, 0.65, 1.0), 2.0)
	draw_line(Vector2(-138.0, -153.0), Vector2(-138.0, -140.0), Color(0.90, 0.82, 0.65, 1.0), 2.0)
	var pillow: Rect2 = Rect2(-186.0, -158.0, 18.0, 12.0)
	_draw_rounded_rect(pillow, Color(0.96, 0.94, 0.88, 1.0), 4.0)
	_draw_rect_outline(pillow, OUTLINE)


func _draw_shelves_and_supplies() -> void:
	# Sturdy wooden shelf on upper right wall [50, 185] at y = -165
	var shelf: Rect2 = Rect2(50.0, -165.0, 135.0, 7.0)
	draw_rect(shelf, WOOD_BEAM)
	_draw_rect_outline(shelf, OUTLINE)
	
	# Vintage books
	var book_cols: Array[Color] = [
		Color(0.82, 0.32, 0.28, 1.0),
		Color(0.28, 0.52, 0.65, 1.0),
		Color(0.35, 0.62, 0.38, 1.0),
		Color(0.85, 0.65, 0.24, 1.0)
	]
	for idx in 4:
		var bx: float = 56.0 + float(idx) * 11.0
		var h: float = 14.0 if (idx % 2 == 0) else 17.0
		var br: Rect2 = Rect2(bx, -165.0 - h, 9.0, h)
		draw_rect(br, book_cols[idx])
		_draw_rect_outline(br, OUTLINE)
		draw_line(Vector2(bx + 4.5, -165.0 - h), Vector2(bx + 4.5, -165.0), Color(1, 1, 1, 0.25), 1.0)
	
	# Canned food tins / Mason jars
	var can_cols: Array[Color] = [Color(0.72, 0.74, 0.78, 1.0), Color(0.82, 0.40, 0.25, 1.0), Color(0.92, 0.78, 0.40, 1.0)]
	for c_idx in 3:
		var cx: float = 110.0 + float(c_idx) * 14.0
		var cr: Rect2 = Rect2(cx, -177.0, 11.0, 12.0)
		_draw_rounded_rect(cr, can_cols[c_idx], 2.0)
		_draw_rect_outline(cr, OUTLINE)
		# Label strip
		draw_rect(Rect2(cx + 1.0, -173.0, 9.0, 4.0), Color(0.95, 0.95, 0.90, 0.9))
	
	# Small glass water jar with blue tint
	var jar: Rect2 = Rect2(160.0, -180.0, 13.0, 15.0)
	_draw_rounded_rect(jar, Color(0.65, 0.85, 0.95, 0.7), 3.0)
	_draw_rect_outline(jar, OUTLINE)
	draw_rect(Rect2(162.0, -182.0, 9.0, 2.5), WOOD_BEAM)


func _draw_steaming_mug() -> void:
	# Cute steaming tea mug on the window shelf at x = 145, y = -140
	var mug: Rect2 = Rect2(142.0, -150.0, 10.0, 10.0)
	_draw_rounded_rect(mug, Color(0.95, 0.88, 0.78, 1.0), 2.0)
	_draw_rect_outline(mug, OUTLINE)
	# Handle
	draw_arc(Vector2(152.0, -145.0), 3.0, -PI * 0.5, PI * 0.5, 8, OUTLINE, 1.5)
	
	# Rising steam wiggles
	for s in 2:
		var sx: float = 145.0 + float(s) * 4.0
		var off1: float = sin(_time * 2.0 + float(s)) * 2.0
		var off2: float = cos(_time * 2.0 + float(s)) * 2.5
		var steam_pts: PackedVector2Array = PackedVector2Array([
			Vector2(sx, -152.0),
			Vector2(sx + off1, -158.0),
			Vector2(sx + off2, -164.0)
		])
		draw_polyline(steam_pts, Color(1.0, 1.0, 1.0, 0.45), 1.2)


func _draw_window_curtains() -> void:
	# 1. Mezzanine Loft Window (Positioned cleanly above the 2nd floor at y = -196 to -160)
	var loft_win: Rect2 = Rect2(-162.0, -196.0, 44.0, 36.0)
	draw_rect(loft_win, Color(0.98, 0.85, 0.52, 0.90))
	draw_circle(Vector2(-140.0, -178.0), 12.0, Color(1.0, 0.95, 0.72, 0.95))
	draw_line(Vector2(-162.0, -178.0), Vector2(-118.0, -178.0), WOOD_BEAM, 1.8)
	draw_line(Vector2(-140.0, -196.0), Vector2(-140.0, -160.0), WOOD_BEAM, 1.8)
	_draw_rect_outline(loft_win, WOOD_BEAM)

	# Timber windowsill shelf at y = -160 (rests 20px above mezzanine floor y = -140)
	var loft_sill: Rect2 = Rect2(-166.0, -160.0, 52.0, 3.5)
	draw_rect(loft_sill, WOOD_BEAM)
	_draw_rect_outline(loft_sill, OUTLINE)

	# 2. Loft Curtains flanking the window
	var drape_col: Color = Color(0.85, 0.45, 0.40, 0.95)
	# Left drape
	draw_colored_polygon(PackedVector2Array([
		Vector2(-168.0, -200.0),
		Vector2(-156.0, -200.0),
		Vector2(-160.0, -178.0),
		Vector2(-155.0, -158.0),
		Vector2(-168.0, -158.0)
	]), drape_col)
	_draw_polyline_loop([
		Vector2(-168.0, -200.0),
		Vector2(-156.0, -200.0),
		Vector2(-160.0, -178.0),
		Vector2(-155.0, -158.0),
		Vector2(-168.0, -158.0)
	], OUTLINE)

	# Right drape
	draw_colored_polygon(PackedVector2Array([
		Vector2(-124.0, -200.0),
		Vector2(-112.0, -200.0),
		Vector2(-112.0, -158.0),
		Vector2(-125.0, -158.0),
		Vector2(-120.0, -178.0)
	]), drape_col)
	_draw_polyline_loop([
		Vector2(-124.0, -200.0),
		Vector2(-112.0, -200.0),
		Vector2(-112.0, -158.0),
		Vector2(-125.0, -158.0),
		Vector2(-120.0, -178.0)
	], OUTLINE)

	# Curtain rod
	draw_line(Vector2(-172.0, -200.0), Vector2(-108.0, -200.0), WOOD_BEAM, 2.5)

	# 3. Ground Floor Window (Above stove/armchair from y = -70 to -30)
	var gnd_win: Rect2 = Rect2(-155.0, -68.0, 42.0, 36.0)
	draw_rect(gnd_win, Color(0.98, 0.85, 0.52, 0.85))
	draw_circle(Vector2(-134.0, -50.0), 10.0, Color(1.0, 0.95, 0.72, 0.90))
	draw_line(Vector2(-155.0, -50.0), Vector2(-113.0, -50.0), WOOD_BEAM, 1.8)
	draw_line(Vector2(-134.0, -68.0), Vector2(-134.0, -32.0), WOOD_BEAM, 1.8)
	_draw_rect_outline(gnd_win, WOOD_BEAM)

	var gnd_sill: Rect2 = Rect2(-158.0, -32.0, 48.0, 3.0)
	draw_rect(gnd_sill, WOOD_BEAM)
	_draw_rect_outline(gnd_sill, OUTLINE)


func _draw_mezzanine_railing() -> void:
	# Low timber safety railing on mezzanine floor edge, opening at [136, 164] for ladder
	# Left railing section: -185.0 to 136.0
	var left_top_rail: Rect2 = Rect2(-185.0, -149.0, 321.0, 3.5)
	draw_rect(left_top_rail, WOOD_BEAM)
	_draw_rect_outline(left_top_rail, OUTLINE)

	# Vertical timber balusters along left section
	var bx: float = -180.0
	while bx < 132.0:
		draw_line(Vector2(bx, -140.0), Vector2(bx, -149.0), WOOD_LINE, 1.8)
		bx += 16.0
	# Sturdy gatepost at hatch edge x = 136
	draw_line(Vector2(136.0, -140.0), Vector2(136.0, -152.0), WOOD_BEAM, 3.5)
	draw_circle(Vector2(136.0, -152.0), 2.0, Color(0.85, 0.70, 0.30, 1.0)) # Brass post finial

	# Right railing section: 164.0 to 195.0
	var right_top_rail: Rect2 = Rect2(164.0, -149.0, 31.0, 3.5)
	draw_rect(right_top_rail, WOOD_BEAM)
	_draw_rect_outline(right_top_rail, OUTLINE)
	draw_line(Vector2(164.0, -140.0), Vector2(164.0, -152.0), WOOD_BEAM, 3.5)
	draw_circle(Vector2(164.0, -152.0), 2.0, Color(0.85, 0.70, 0.30, 1.0))
	draw_line(Vector2(180.0, -140.0), Vector2(180.0, -149.0), WOOD_LINE, 1.8)

	# Cozy dangling fairy lights along the left railing edge
	var r_wire: PackedVector2Array = PackedVector2Array()
	var r_count: int = 10
	for i in r_count:
		var t: float = float(i) / float(r_count - 1)
		var lx: float = lerpf(-180.0, 130.0, t)
		var sag: float = sin(t * PI * 2.5) * 5.0
		var ly: float = -142.0 + sag
		r_wire.append(Vector2(lx, ly))
		var pulse: float = 0.7 + sin(_time * 2.8 + float(i) * 1.8) * 0.3
		draw_circle(Vector2(lx, ly + 2.0), 2.0, Color(1.0, 0.86, 0.50, pulse))
		draw_circle(Vector2(lx, ly + 2.0), 4.5, Color(1.0, 0.75, 0.35, 0.22 * pulse))
	draw_polyline(r_wire, FAIRY_WIRE, 1.0)


func _draw_ground_window_light_shaft() -> void:
	if _tm == null: return
	var is_night = bool(_tm.get("is_night"))
	if is_night:
		# Moonlight shaft
		var shaft_poly: PackedVector2Array = PackedVector2Array([
			Vector2(-232.0, -70.0),
			Vector2(-232.0, 0.0),
			Vector2(-310.0, 16.0),
			Vector2(-340.0, -10.0)
		])
		draw_colored_polygon(shaft_poly, Color(0.6, 0.7, 0.9, 0.08))
		return
		
	var w = "sunny"
	if get_node_or_null("/root/LevelSetup"): w = get_node("/root/LevelSetup").get("current_weather")
	if w != "sunny": return # Only draw strong sun shafts if sunny
		
	var ratio = _tm.get("time_elapsed") / max(float(_tm.get("day_duration_seconds")), 1.0)
	
	# Light sweeps from left (morning) to right (evening)
	var sweep = lerp(-150.0, 150.0, ratio)
	var color_a = Color(1.0, 0.9, 0.7, 0.15) # Morning warm
	var color_b = Color(1.0, 0.7, 0.4, 0.15) # Evening orange
	var sun_col = color_a.lerp(color_b, ratio)
	
	var shaft: PackedVector2Array = PackedVector2Array([
		Vector2(sweep - 100.0, -400.0), # Top left of window
		Vector2(sweep + 50.0, -400.0), # Top right
		Vector2(sweep + 250.0, 100.0), # Bottom right on floor
		Vector2(sweep - 200.0, 100.0)  # Bottom left on floor
	])
	draw_colored_polygon(shaft, sun_col)
	
	# Dust particles in sun beam
	var dust_count = 15
	for i in dust_count:
		var dx = sweep + sin(_time + float(i)*1.5) * 100.0 + (float(i) * 10.0)
		var dy = -200.0 + fmod((_time * -15.0 + float(i) * 30.0), 300.0)
		var alpha = sin(_time * 2.0 + float(i)) * 0.8
		if alpha > 0:
			draw_circle(Vector2(dx, dy), 1.5, Color(1.0, 0.9, 0.6, alpha * 0.8))


func _draw_fairy_lights() -> void:
	# String of cozy fairy lights hanging under the ceiling
	var is_night: bool = _tm != null and bool(_tm.get("is_night"))
	var wire_pts: PackedVector2Array = PackedVector2Array()
	var bulb_count: int = 12
	var bulb_colors: Array[Color] = [
		Color(1.0, 0.82, 0.40, 1.0), # warm yellow
		Color(1.0, 0.55, 0.45, 1.0), # soft peach
		Color(0.60, 0.88, 0.75, 1.0), # cozy mint
		Color(1.0, 0.90, 0.65, 1.0)  # golden
	]
	
	for i in bulb_count:
		var t: float = float(i) / float(bulb_count - 1)
		var x: float = lerpf(-190.0, 190.0, t)
		var sag: float = sin(t * PI) * 14.0
		var y: float = -194.0 + sag
		wire_pts.append(Vector2(x, y))
		
		# Draw bulb
		var flicker: float = 0.7 + sin(_time * 3.0 + float(i) * 1.5) * 0.3
		var b_col: Color = bulb_colors[i % bulb_colors.size()]
		# Extra night bloom halo
		if is_night:
			draw_circle(Vector2(x, y + 3.0), 9.5, Color(b_col.r, b_col.g, b_col.b, 0.38 * flicker))
		# Outer glow halo
		draw_circle(Vector2(x, y + 3.0), 4.5, Color(b_col.r, b_col.g, b_col.b, 0.35 * flicker))
		# Inner bulb
		draw_circle(Vector2(x, y + 3.0), 2.2, Color(b_col.r, b_col.g, b_col.b, flicker))
		draw_circle(Vector2(x, y + 2.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))
	
	draw_polyline(wire_pts, FAIRY_WIRE, 1.2)


func _draw_pitched_roof_and_rooftop_stations() -> void:
	# 1. Timber Gable Triangle Wall [(-234, -215), (0, -284), (234, -215)]
	var gable_poly: PackedVector2Array = PackedVector2Array([
		Vector2(-234.0, -215.0),
		Vector2(0.0, -284.0),
		Vector2(234.0, -215.0)
	])
	draw_colored_polygon(gable_poly, WOOD_PLANK_A * 0.92)
	_draw_polyline_loop(gable_poly, OUTLINE)

	# Horizontal planks inside the gable
	var gy: float = -222.0
	while gy > -280.0:
		var t_fac: float = (gy - (-215.0)) / (-284.0 - (-215.0))
		var cur_w: float = lerpf(234.0, 0.0, t_fac)
		draw_line(Vector2(-cur_w, gy), Vector2(cur_w, gy), WOOD_LINE, 1.2)
		gy -= 14.0

	# Vertical ridge support beam
	draw_line(Vector2(0.0, -215.0), Vector2(0.0, -284.0), WOOD_BEAM, 3.0)

	# 2. Cozy Round Attic Window
	var win_center: Vector2 = Vector2(0.0, -248.0)
	draw_circle(win_center, 14.0, WOOD_BEAM)
	_draw_circle_outline(win_center, 14.0, OUTLINE)
	draw_circle(win_center, 10.5, Color(0.98, 0.82, 0.45, 0.8))
	draw_line(Vector2(-10.5, -248.0), Vector2(10.5, -248.0), OUTLINE, 1.5)
	draw_line(Vector2(0.0, -258.5), Vector2(0.0, -237.5), OUTLINE, 1.5)

	# 3. 2.5D Slanted Roof Covering & Eaves
	var left_slope: PackedVector2Array = PackedVector2Array([
		Vector2(0.0, -284.0),
		Vector2(4.0, -287.0),
		Vector2(-258.0, -211.0),
		Vector2(-254.0, -206.0),
		Vector2(-234.0, -215.0)
	])
	draw_colored_polygon(left_slope, Color(0.24, 0.16, 0.12, 1.0))
	_draw_polyline_loop(left_slope, OUTLINE)

	var right_slope: PackedVector2Array = PackedVector2Array([
		Vector2(0.0, -284.0),
		Vector2(-4.0, -287.0),
		Vector2(258.0, -211.0),
		Vector2(254.0, -206.0),
		Vector2(234.0, -215.0)
	])
	draw_colored_polygon(right_slope, Color(0.20, 0.13, 0.09, 1.0))
	_draw_polyline_loop(right_slope, OUTLINE)

	# Overhang rafter brackets under eaves
	for bx in [-240.0, -200.0, 200.0, 240.0]:
		var by: float = lerpf(-211.0, -284.0, absf(bx) / 258.0)
		draw_line(Vector2(bx, by), Vector2(bx, by + 8.0), WOOD_BEAM, 2.5)

	# 4. Metal Chimney Pipe with Dense Smooth Smoke Stream
	var cx: float = -90.0
	draw_line(Vector2(cx, -215.0), Vector2(cx, -295.0), Color(0.28, 0.30, 0.32, 1.0), 5.0)
	draw_line(Vector2(cx, -215.0), Vector2(cx, -295.0), OUTLINE, 1.2)
	var cap: Rect2 = Rect2(cx - 5.0, -298.0, 10.0, 3.5)
	draw_rect(cap, Color(0.35, 0.38, 0.40, 1.0))
	_draw_rect_outline(cap, OUTLINE)

	# Smooth, dense connected stream of overlapping smoke puffs
	var is_night_smoke: bool = _tm != null and bool(_tm.get("is_night"))
	var puff_count: int = 12
	for s_idx in puff_count:
		var p: float = fmod(_time * 0.35 + float(s_idx) / float(puff_count), 1.0)
		var sx: float = cx + p * 24.0 + sin(_time * 1.2 + float(s_idx) * 0.7) * 4.5
		var sy: float = -300.0 - p * 42.0
		var s_rad: float = 3.2 + p * 11.0
		var alpha_base: float = 0.55 if is_night_smoke else 0.35
		var s_alpha: float = sin(p * PI) * alpha_base
		draw_circle(Vector2(sx, sy), s_rad, Color(0.92, 0.89, 0.84, s_alpha))

	# 5. Two Fortified Rooftop AK Platforms with Beveled Roof Wedges
	# Left AK Station Platform at x = -130.0
	var lp: Rect2 = Rect2(-158.0, -217.0, 56.0, 5.0)
	draw_rect(lp, WOOD_BEAM)
	_draw_rect_outline(lp, OUTLINE)
	for sb_x in [-152.0, -132.0, -112.0]:
		_draw_rounded_rect(Rect2(sb_x, -223.0, 18.0, 7.0), Color(0.46, 0.44, 0.34, 1.0), 2.0)
		_draw_rect_outline(Rect2(sb_x, -223.0, 18.0, 7.0), OUTLINE)

	# Right AK Station Platform at x = 130.0
	var rp: Rect2 = Rect2(102.0, -217.0, 56.0, 5.0)
	draw_rect(rp, WOOD_BEAM)
	_draw_rect_outline(rp, OUTLINE)
	for sb_x in [108.0, 128.0, 148.0]:
		_draw_rounded_rect(Rect2(sb_x, -223.0, 18.0, 7.0), Color(0.46, 0.44, 0.34, 1.0), 2.0)
		_draw_rect_outline(Rect2(sb_x, -223.0, 18.0, 7.0), OUTLINE)


func _draw_ladder() -> void:
	# Interior Cabin Ladder at x = 150.0 rising through mezzanine hatch [136, 164]
	var left_x: float = 142.0
	var right_x: float = 158.0
	var top_y: float = -140.0
	var handle_top: float = -158.0

	# 1. Contact shadow on ground floor
	draw_ellipse(Vector2(150.0, 2.0), 12.0, 4.0, Color(0.0, 0.0, 0.0, 0.35))

	# 2. Arched wooden safety handrails extending above mezzanine floor
	draw_line(Vector2(left_x, top_y), Vector2(left_x, handle_top + 4.0), WOOD_BEAM, 3.5)
	draw_arc(Vector2(left_x - 3.0, handle_top + 4.0), 3.0, -PI, 0.0, 6, WOOD_BEAM, 3.0)
	draw_line(Vector2(right_x, top_y), Vector2(right_x, handle_top + 4.0), WOOD_BEAM, 3.5)
	draw_arc(Vector2(right_x + 3.0, handle_top + 4.0), 3.0, -PI, 0.0, 6, WOOD_BEAM, 3.0)

	# 3. Main vertical ladder rails from ground y = 0.0 to mezzanine y = -140.0
	draw_line(Vector2(left_x, 0.0), Vector2(left_x, top_y), WOOD_BEAM, 4.0)
	draw_line(Vector2(left_x, 0.0), Vector2(left_x, top_y), OUTLINE, 1.2)
	draw_line(Vector2(right_x, 0.0), Vector2(right_x, top_y), WOOD_BEAM, 4.0)
	draw_line(Vector2(right_x, 0.0), Vector2(right_x, top_y), OUTLINE, 1.2)

	# 4. Wooden rungs with brass rivet fasteners
	var rung_y: float = -14.0
	while rung_y >= top_y:
		draw_line(Vector2(left_x - 2.0, rung_y), Vector2(right_x + 2.0, rung_y), WOOD_PLANK_A, 3.0)
		draw_line(Vector2(left_x - 2.0, rung_y), Vector2(right_x + 2.0, rung_y), OUTLINE, 1.0)
		draw_circle(Vector2(left_x, rung_y), 1.3, Color(0.85, 0.70, 0.30, 1.0))
		draw_circle(Vector2(right_x, rung_y), 1.3, Color(0.85, 0.70, 0.30, 1.0))
		rung_y -= 14.0


func _draw_polyline_loop(pts_array: PackedVector2Array, col: Color) -> void:
	var p: PackedVector2Array = pts_array.duplicate()
	p.append(pts_array[0])
	draw_polyline(p, col, 1.5)


func _draw_rounded_rect(r: Rect2, col: Color, radius: float) -> void:
	draw_rect(r, col)
	draw_circle(Vector2(r.position.x + radius, r.position.y + radius), radius, col)
	draw_circle(Vector2(r.position.x + r.size.x - radius, r.position.y + radius), radius, col)
	draw_circle(Vector2(r.position.x + radius, r.position.y + r.size.y - radius), radius, col)
	draw_circle(Vector2(r.position.x + r.size.x - radius, r.position.y + r.size.y - radius), radius, col)


func _draw_rect_outline(r: Rect2, col: Color) -> void:
	var pts: PackedVector2Array = PackedVector2Array([
		r.position,
		Vector2(r.position.x + r.size.x, r.position.y),
		Vector2(r.position.x + r.size.x, r.position.y + r.size.y),
		Vector2(r.position.x, r.position.y + r.size.y),
		r.position
	])
	draw_polyline(pts, col, 1.5)


func _draw_circle_outline(c: Vector2, rad: float, col: Color) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i in 16:
		var a: float = TAU * float(i) / 16.0
		pts.append(c + Vector2(cos(a), sin(a)) * rad)
	pts.append(pts[0])
	draw_polyline(pts, col, 1.5)


func _draw_leather_armchair() -> void:
	# Leather armchair near stove at x = -38.0, y = 0.0
	var cx: float = -38.0
	var cy: float = 0.0
	# 2.5D perspective contact shadow on floor
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(cx - 16.0, cy + 2.0),
			Vector2(cx + 16.0, cy + 2.0),
			Vector2(cx + 12.0, cy + 8.0),
			Vector2(cx - 12.0, cy + 8.0)
		]),
		Color(0.0, 0.0, 0.0, 0.35)
	)
	# Wooden feet
	draw_line(Vector2(cx - 10.0, cy), Vector2(cx - 12.0, cy + 4.0), WOOD_LINE, 2.0)
	draw_line(Vector2(cx + 10.0, cy), Vector2(cx + 12.0, cy + 4.0), WOOD_LINE, 2.0)
	# 2.5D Main seat cushion with top plane and front plane
	var seat_top: PackedVector2Array = PackedVector2Array([
		Vector2(cx - 12.0, cy - 16.0),
		Vector2(cx + 12.0, cy - 16.0),
		Vector2(cx + 14.0, cy - 10.0),
		Vector2(cx - 14.0, cy - 10.0)
	])
	draw_colored_polygon(seat_top, Color(0.46, 0.30, 0.20, 1.0))
	_draw_polyline_loop(seat_top, OUTLINE)
	var seat_front: Rect2 = Rect2(cx - 14.0, cy - 10.0, 28.0, 8.0)
	_draw_rounded_rect(seat_front, Color(0.38, 0.24, 0.16, 1.0), 2.0)
	_draw_rect_outline(seat_front, OUTLINE)
	# Backrest with 3D bevel
	var back: Rect2 = Rect2(cx - 12.0, cy - 32.0, 24.0, 18.0)
	_draw_rounded_rect(back, Color(0.44, 0.28, 0.18, 1.0), 4.0)
	_draw_rect_outline(back, OUTLINE)
	# Button tufting on backrest
	draw_circle(Vector2(cx - 5.0, cy - 24.0), 1.2, OUTLINE)
	draw_circle(Vector2(cx + 5.0, cy - 24.0), 1.2, OUTLINE)
	draw_circle(Vector2(cx, cy - 18.0), 1.2, OUTLINE)
	# 2.5D Armrests with top planes
	var arm_l: Rect2 = Rect2(cx - 16.0, cy - 22.0, 5.0, 14.0)
	var arm_r: Rect2 = Rect2(cx + 11.0, cy - 22.0, 5.0, 14.0)
	_draw_rounded_rect(arm_l, Color(0.34, 0.20, 0.14, 1.0), 2.0)
	_draw_rect_outline(arm_l, OUTLINE)
	_draw_rounded_rect(arm_r, Color(0.34, 0.20, 0.14, 1.0), 2.0)
	_draw_rect_outline(arm_r, OUTLINE)
	# Cozy tartan throw blanket draped over armrest
	var blanket: Rect2 = Rect2(cx + 10.0, cy - 20.0, 7.0, 12.0)
	draw_rect(blanket, Color(0.68, 0.28, 0.22, 1.0))
	draw_line(Vector2(cx + 10.0, cy - 15.0), Vector2(cx + 17.0, cy - 15.0), Color(0.85, 0.72, 0.38, 1.0), 1.2)


func _draw_workbench_and_tools() -> void:
	# Heavy carpenter workbench at x = 115.0, y = 0.0
	var wx: float = 115.0
	var wy: float = 0.0
	# 2.5D shadow under workbench
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(wx - 24.0, wy + 2.0),
			Vector2(wx + 24.0, wy + 2.0),
			Vector2(wx + 20.0, wy + 8.0),
			Vector2(wx - 20.0, wy + 8.0)
		]),
		Color(0.0, 0.0, 0.0, 0.35)
	)
	# Sturdy wooden legs in perspective
	draw_rect(Rect2(wx - 20.0, wy - 18.0, 5.0, 20.0), WOOD_BEAM)
	draw_rect(Rect2(wx + 15.0, wy - 18.0, 5.0, 20.0), WOOD_BEAM)
	draw_rect(Rect2(wx - 14.0, wy - 20.0, 4.0, 18.0), WOOD_BEAM * 0.75) # back leg
	draw_rect(Rect2(wx + 9.0, wy - 20.0, 4.0, 18.0), WOOD_BEAM * 0.75)  # back leg
	draw_line(Vector2(wx - 20.0, wy - 4.0), Vector2(wx + 20.0, wy - 4.0), WOOD_BEAM, 2.5)
	# 2.5D Tabletop (Perspective top plane + front fascia edge)
	var top_surface: PackedVector2Array = PackedVector2Array([
		Vector2(wx - 22.0, wy - 26.0),
		Vector2(wx + 22.0, wy - 26.0),
		Vector2(wx + 25.0, wy - 20.0),
		Vector2(wx - 25.0, wy - 20.0)
	])
	draw_colored_polygon(top_surface, WOOD_PLANK_A * 1.05)
	_draw_polyline_loop(top_surface, OUTLINE)
	var front_fascia: Rect2 = Rect2(wx - 25.0, wy - 20.0, 50.0, 5.0)
	draw_rect(front_fascia, WOOD_PLANK_B)
	_draw_rect_outline(front_fascia, OUTLINE)

	# Blueprint map unrolled on table
	var bp: PackedVector2Array = PackedVector2Array([
		Vector2(wx - 14.0, wy - 25.0),
		Vector2(wx + 4.0, wy - 25.0),
		Vector2(wx + 6.0, wy - 21.0),
		Vector2(wx - 12.0, wy - 21.0)
	])
	draw_colored_polygon(bp, Color(0.25, 0.45, 0.70, 1.0))
	draw_line(Vector2(wx - 11.0, wy - 23.0), Vector2(wx + 4.0, wy - 23.0), Color(0.70, 0.85, 1.0, 0.8), 1.0)
	# Brass oil desk lamp
	draw_rect(Rect2(wx + 11.0, wy - 27.0, 6.0, 6.0), Color(0.85, 0.70, 0.30, 1.0))
	draw_circle(Vector2(wx + 14.0, wy - 29.0), 3.5, Color(1.0, 0.90, 0.50, 0.6))
	# Hanging tools on the wall behind
	draw_line(Vector2(wx - 14.0, wy - 36.0), Vector2(wx - 14.0, wy - 46.0), Color(0.6, 0.62, 0.65, 1.0), 2.0)
	draw_circle(Vector2(wx - 14.0, wy - 46.0), 1.5, WOOD_BEAM)
	draw_line(Vector2(wx - 6.0, wy - 36.0), Vector2(wx - 6.0, wy - 44.0), Color(0.5, 0.52, 0.55, 1.0), 1.8)
	draw_line(Vector2(wx + 2.0, wy - 35.0), Vector2(wx + 2.0, wy - 45.0), WOOD_PLANK_B, 2.0)
	draw_rect(Rect2(wx, wy - 46.0, 6.0, 3.0), Color(0.4, 0.42, 0.45, 1.0))


func _draw_gun_rack() -> void:
	var gx: float = 115.0
	var gy: float = -56.0
	draw_line(Vector2(gx - 16.0, gy - 8.0), Vector2(gx - 16.0, gy + 8.0), WOOD_BEAM, 3.0)
	draw_line(Vector2(gx + 16.0, gy - 8.0), Vector2(gx + 16.0, gy + 8.0), WOOD_BEAM, 3.0)
	draw_line(Vector2(gx - 18.0, gy - 4.0), Vector2(gx + 18.0, gy - 4.0), Color(0.35, 0.38, 0.40, 1.0), 1.8)
	draw_line(Vector2(gx - 18.0, gy - 3.5), Vector2(gx - 8.0, gy - 3.5), WOOD_PLANK_A, 2.8)
	draw_rect(Rect2(gx - 4.0, gy - 7.0, 7.0, 2.0), Color(0.2, 0.22, 0.25, 1.0))
	draw_line(Vector2(gx - 16.0, gy + 4.0), Vector2(gx + 16.0, gy + 4.0), Color(0.32, 0.34, 0.36, 1.0), 2.2)
	draw_line(Vector2(gx - 16.0, gy + 4.5), Vector2(gx - 7.0, gy + 4.5), WOOD_PLANK_A, 3.0)


func _draw_turntable() -> void:
	var tx: float = 52.0
	var ty: float = 0.0
	# 2.5D contact shadow
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(tx - 12.0, ty + 2.0),
			Vector2(tx + 12.0, ty + 2.0),
			Vector2(tx + 10.0, ty + 7.0),
			Vector2(tx - 10.0, ty + 7.0)
		]),
		Color(0.0, 0.0, 0.0, 0.35)
	)
	var stand: Rect2 = Rect2(tx - 9.0, ty - 18.0, 18.0, 18.0)
	draw_rect(stand, WOOD_BEAM)
	_draw_rect_outline(stand, OUTLINE)
	draw_circle(Vector2(tx, ty - 9.0), 1.2, Color(0.85, 0.70, 0.30, 1.0))
	# 2.5D Turntable box with angled top
	var box_top: PackedVector2Array = PackedVector2Array([
		Vector2(tx - 8.0, ty - 26.0),
		Vector2(tx + 8.0, ty - 26.0),
		Vector2(tx + 9.0, ty - 22.0),
		Vector2(tx - 9.0, ty - 22.0)
	])
	draw_colored_polygon(box_top, Color(0.52, 0.38, 0.26, 1.0))
	_draw_polyline_loop(box_top, OUTLINE)
	var box_front: Rect2 = Rect2(tx - 9.0, ty - 22.0, 18.0, 4.0)
	draw_rect(box_front, Color(0.42, 0.28, 0.18, 1.0))
	_draw_rect_outline(box_front, OUTLINE)
	# Angled vinyl record
	draw_circle(Vector2(tx - 1.0, ty - 24.0), 4.5, Color(0.12, 0.12, 0.14, 1.0))
	draw_circle(Vector2(tx - 1.0, ty - 24.0), 1.8, Color(0.85, 0.30, 0.25, 1.0))
	for note_idx in 2:
		var n_phase: float = fmod(_time * 0.8 + float(note_idx) * 1.5, 3.0) / 3.0
		var ny: float = ty - 28.0 - n_phase * 22.0
		var nx: float = tx + sin(_time * 2.0 + float(note_idx)) * 4.0
		var n_alpha: float = sin(n_phase * PI) * 0.85
		var n_col: Color = Color(1.0, 0.88, 0.65, n_alpha)
		draw_circle(Vector2(nx, ny), 1.5, n_col)
		draw_line(Vector2(nx + 1.2, ny), Vector2(nx + 1.2, ny - 4.5), n_col, 1.2)
		draw_line(Vector2(nx + 1.2, ny - 4.5), Vector2(nx + 3.5, ny - 3.5), n_col, 1.2)


func _draw_supply_crates() -> void:
	# True 2.5D Isometric wooden cargo crates at x = 175.0, y = 0.0
	var cx: float = 175.0
	var cy: float = 0.0
	# 2.5D contact shadow
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(cx - 15.0, cy + 2.0),
			Vector2(cx + 15.0, cy + 2.0),
			Vector2(cx + 12.0, cy + 8.0),
			Vector2(cx - 12.0, cy + 8.0)
		]),
		Color(0.0, 0.0, 0.0, 0.35)
	)
	# Bottom crate: Front face + Top face + Side face
	var b_front: Rect2 = Rect2(cx - 12.0, cy - 18.0, 22.0, 18.0)
	draw_rect(b_front, WOOD_PLANK_A)
	_draw_rect_outline(b_front, OUTLINE)
	draw_line(Vector2(cx - 12.0, cy - 18.0), Vector2(cx + 10.0, cy), OUTLINE, 1.2)
	# Bottom crate top face
	var b_top: PackedVector2Array = PackedVector2Array([
		Vector2(cx - 12.0, cy - 18.0),
		Vector2(cx + 10.0, cy - 18.0),
		Vector2(cx + 14.0, cy - 23.0),
		Vector2(cx - 8.0, cy - 23.0)
	])
	draw_colored_polygon(b_top, WOOD_PLANK_A * 1.1)
	_draw_polyline_loop(b_top, OUTLINE)
	# Iron corner braces
	draw_circle(Vector2(cx - 9.0, cy - 15.0), 1.5, Color(0.4, 0.42, 0.45, 1.0))
	draw_circle(Vector2(cx + 7.0, cy - 15.0), 1.5, Color(0.4, 0.42, 0.45, 1.0))
	
	# Top smaller crate with 2.5D top face
	var t_front: Rect2 = Rect2(cx - 8.0, cy - 36.0, 18.0, 14.0)
	draw_rect(t_front, WOOD_PLANK_B)
	_draw_rect_outline(t_front, OUTLINE)
	draw_line(Vector2(cx + 10.0, cy - 36.0), Vector2(cx - 8.0, cy - 22.0), OUTLINE, 1.2)
	var t_top: PackedVector2Array = PackedVector2Array([
		Vector2(cx - 8.0, cy - 36.0),
		Vector2(cx + 10.0, cy - 36.0),
		Vector2(cx + 13.0, cy - 40.0),
		Vector2(cx - 5.0, cy - 40.0)
	])
	draw_colored_polygon(t_top, WOOD_PLANK_B * 1.1)
	_draw_polyline_loop(t_top, OUTLINE)


func _draw_guitar() -> void:
	# Acoustic guitar leaning at x = -125.0, y = -140.0
	var gx: float = -125.0
	var gy: float = -140.0
	# Guitar body
	draw_circle(Vector2(gx, gy - 8.0), 7.0, Color(0.78, 0.52, 0.28, 1.0))
	draw_circle(Vector2(gx + 1.5, gy - 16.0), 5.5, Color(0.78, 0.52, 0.28, 1.0))
	_draw_circle_outline(Vector2(gx, gy - 8.0), 7.0, OUTLINE)
	_draw_circle_outline(Vector2(gx + 1.5, gy - 16.0), 5.5, OUTLINE)
	# Soundhole
	draw_circle(Vector2(gx + 1.0, gy - 12.0), 2.2, Color(0.2, 0.14, 0.10, 1.0))
	# Neck and headstock
	draw_line(Vector2(gx + 2.0, gy - 16.0), Vector2(gx + 7.0, gy - 32.0), WOOD_BEAM, 2.5)
	draw_rect(Rect2(gx + 6.0, gy - 36.0, 4.0, 5.0), WOOD_BEAM)


func _update_badge_cache() -> void:
	_badge_cache[0] = GameState != null and int(GameState.stats.get("days_survived", 0)) >= 7
	_badge_cache[1] = GameState != null and int(GameState.stats.get("zombies_killed", 0)) >= 50
	_badge_cache[2] = MailboxManager != null and int(MailboxManager.sender_affinity.get("Bác Sáu (Câu Cá Sa Mạc)", 0)) >= 60
	_badge_cache[3] = GameState != null and int(GameState.stats.get("plants_harvested", 0)) >= 15
	_badge_cache[4] = GameState != null and int(GameState.stats.get("walls_built", 0)) >= 10
	_badge_cache[5] = GameState != null and bool(GameState.meal_buff)
	_badge_cache[6] = CabinDecorationManager != null and CabinDecorationManager.cozy_score >= 80

func _draw_wooden_badge_wall() -> void:
	# Wooden Medal Badges Wall mounted on 2nd floor loft wall
	var board_rect := Rect2(-75.0, -188.0, 102.0, 24.0)
	draw_rect(board_rect, Color(0.24, 0.15, 0.10, 1.0))
	_draw_rect_outline(board_rect, OUTLINE)

	# Brass corner screws
	draw_circle(Vector2(-72.0, -185.0), 1.2, Color(0.88, 0.72, 0.30))
	draw_circle(Vector2(24.0, -185.0), 1.2, Color(0.88, 0.72, 0.30))
	draw_circle(Vector2(-72.0, -167.0), 1.2, Color(0.88, 0.72, 0.30))
	draw_circle(Vector2(24.0, -167.0), 1.2, Color(0.88, 0.72, 0.30))

	# 7 Badges definition
	var badges_unlocked: Array[bool] = _badge_cache

	var start_x: float = -66.0
	for i in 7:
		var bx: float = start_x + float(i) * 14.5
		var by: float = -176.0
		var is_unlocked: bool = badges_unlocked[i]

		if is_unlocked:
			# Unlocked Medal: Shining brass & silk ribbon
			draw_line(Vector2(bx - 2.5, by - 7.0), Vector2(bx, by - 3.0), Color(0.85, 0.25, 0.25), 2.0)
			draw_line(Vector2(bx + 2.5, by - 7.0), Vector2(bx, by - 3.0), Color(0.25, 0.45, 0.85), 2.0)
			draw_circle(Vector2(bx, by), 4.2, Color(1.0, 0.85, 0.35, 1.0))
			_draw_circle_outline(Vector2(bx, by), 4.2, OUTLINE)
			draw_circle(Vector2(bx, by), 1.8, Color(1.0, 0.95, 0.75, 1.0))
		else:
			# Locked Badge: Dark engraved wood silhouette
			draw_circle(Vector2(bx, by), 3.5, Color(0.18, 0.12, 0.08, 0.8))
			_draw_circle_outline(Vector2(bx, by), 3.5, Color(0.35, 0.25, 0.18, 0.8))


func _draw_custom_decorations() -> void:
	# 6. Mementos from friends
	if GameState.relics_found.has("golden_fishing_rod"):
		# Dried fish on the wall
		var fish_rect = Rect2(120.0, -110.0, 10.0, 24.0)
		draw_rect(fish_rect, Color(0.6, 0.5, 0.4))
		_draw_rect_outline(fish_rect, OUTLINE)
		draw_line(Vector2(125.0, -110.0), Vector2(125.0, -115.0), Color(0.9, 0.9, 0.9), 1.0)
	if GameState.relics_found.has("chromium_ak_barrel"):
		# Shiny AK barrel on the wall
		var barrel_rect = Rect2(140.0, -110.0, 4.0, 30.0)
		draw_rect(barrel_rect, Color(0.9, 0.9, 0.95))
		_draw_rect_outline(barrel_rect, OUTLINE)

	if CabinDecorationManager == null:
		return

	# 1. Cozy Bohemian Woven Rug (Ground floor living room)
	if CabinDecorationManager.unlocked_decorations.get("cozy_rug", false):
		var rug_rect := Rect2(-42.0, -3.5, 78.0, 4.5)
		draw_rect(rug_rect, Color(0.72, 0.32, 0.26, 1.0))
		_draw_rect_outline(rug_rect, OUTLINE)
		# Fringe tassels
		for fx in [-42.0, 36.0]:
			for fy in [-3.0, -1.0, 1.0]:
				draw_line(Vector2(fx, fy), Vector2(fx + (1.5 if fx > 0 else -1.5), fy), Color(0.92, 0.85, 0.70), 1.0)
		# Geometric diamond patterns
		for dx in [-28.0, -14.0, 0.0, 14.0, 28.0]:
			draw_circle(Vector2(dx, -1.5), 1.6, Color(0.28, 0.65, 0.65, 1.0))
			draw_circle(Vector2(dx, -1.5), 0.8, Color(0.95, 0.88, 0.60, 1.0))

	# 2. Disco Ball (Loft ceiling with orbiting sparkles)
	if CabinDecorationManager.unlocked_decorations.get("disco_ball", false):
		draw_line(Vector2(0.0, -215.0), Vector2(0.0, -196.0), Color(0.4, 0.45, 0.5), 1.2)
		var db_pos := Vector2(0.0, -196.0)
		draw_circle(db_pos, 6.5, Color(0.85, 0.88, 0.95, 1.0))
		_draw_circle_outline(db_pos, 6.5, OUTLINE)
		# Rotating facet sparkles
		for a in 4:
			var ang: float = _time * 2.0 + float(a) * (PI * 0.5)
			var sp_pos := db_pos + Vector2(cos(ang) * 4.5, sin(ang) * 2.5)
			draw_circle(sp_pos, 1.2, Color(1.0, 1.0, 1.0, 0.9))

	# 3. Retro Anime Poster (Ground floor wall)
	if CabinDecorationManager.unlocked_decorations.get("retro_poster", false):
		var p_rect := Rect2(10.0, -84.0, 22.0, 30.0)
		draw_rect(p_rect, Color(0.20, 0.14, 0.10, 1.0))
		_draw_rect_outline(p_rect, OUTLINE)
		# Poster artwork: retro sun and turquoise waves
		draw_rect(Rect2(12.0, -82.0, 18.0, 26.0), Color(0.96, 0.88, 0.70, 1.0))
		draw_circle(Vector2(21.0, -72.0), 6.0, Color(0.95, 0.45, 0.35, 1.0))
		draw_rect(Rect2(12.0, -66.0, 18.0, 10.0), Color(0.25, 0.60, 0.70, 1.0))

	# 4. Super Stove Pipes & Gauge
	if CabinDecorationManager.has_super_stove():
		# Brass copper boiler pipes over stove
		draw_line(Vector2(-72.0, -32.0), Vector2(-72.0, -50.0), Color(0.85, 0.60, 0.30), 3.0)
		draw_line(Vector2(-72.0, -50.0), Vector2(-60.0, -50.0), Color(0.85, 0.60, 0.30), 3.0)
		# Pressure gauge
		draw_circle(Vector2(-60.0, -50.0), 3.5, Color(0.85, 0.85, 0.90))
		_draw_circle_outline(Vector2(-60.0, -50.0), 3.5, OUTLINE)
		draw_line(Vector2(-60.0, -50.0), Vector2(-59.0, -52.0), Color(0.9, 0.2, 0.2), 1.2)

	# 5. Radio on Workbench
	if CabinDecorationManager.has_radio():
		var r_rect := Rect2(82.0, -43.0, 16.0, 11.0)
		draw_rect(r_rect, Color(0.35, 0.24, 0.16, 1.0))
		_draw_rect_outline(r_rect, OUTLINE)
		# Tuning dial & vacuum tube
		draw_circle(Vector2(86.0, -38.0), 2.2, Color(0.85, 0.80, 0.60))
		draw_rect(Rect2(91.0, -41.0, 4.0, 6.0), Color(0.95, 0.55, 0.20, 0.85)) # glowing tube
		# Antenna
		draw_line(Vector2(95.0, -43.0), Vector2(98.0, -56.0), Color(0.65, 0.68, 0.72), 1.2)


func _draw_lantern() -> void:
	var w = "sunny"
	if get_node_or_null("/root/LevelSetup"):
		w = get_node("/root/LevelSetup").get("current_weather")
	
	# Lantern sways more in storm or snow
	var sway_amt = 0.05
	if w == "heavy_rain" or w == "snowstorm" or w == "thick_fog":
		sway_amt = 0.25
	
	var angle = sin(_time * 2.5) * sway_amt
	
	var pivot = Vector2(-20.0, -145.0) # Hung under the mezzanine
	draw_set_transform(pivot, angle, Vector2.ONE)
	
	# Chain
	draw_line(Vector2.ZERO, Vector2(0, 15.0), OUTLINE, 1.5)
	
	# Lantern Body
	var body = Rect2(-6.0, 15.0, 12.0, 16.0)
	draw_rect(body, Color(0.2, 0.2, 0.2))
	_draw_rect_outline(body, OUTLINE)
	
	# Glow
	var is_night: bool = _tm != null and bool(_tm.get("is_night"))
	if is_night or w == "thick_fog" or w == "heavy_rain" or w == "snowstorm":
		var flicker = 0.8 + sin(_time * 15.0) * 0.2
		draw_rect(Rect2(-4.0, 17.0, 8.0, 12.0), Color(1.0, 0.9, 0.5, flicker))
		draw_circle(Vector2(0, 23.0), 30.0, Color(1.0, 0.9, 0.5, 0.15 * flicker))
		
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_interior_overlay() -> void:
	# A warm interior tint to separate cabin from wasteland.
	# Polygons covering the cabin interior area.
	var interior_poly: PackedVector2Array = PackedVector2Array([
		Vector2(-195.0, -195.0),
		Vector2(195.0, -195.0),
		Vector2(195.0, -12.0),
		Vector2(-195.0, -12.0)
	])
	draw_colored_polygon(interior_poly, Color(0.95, 0.6, 0.2, 0.04))

func _update_clock_cache() -> void:
	if _tm == null: return
	_solar_pct_cache = float(_tm.get("current_solar_energy")) / 100.0
	var is_n: bool = bool(_tm.get("is_night"))
	var time_elapsed: float = float(_tm.get("time_elapsed"))
	var dur: float = float(_tm.get("night_duration_seconds") if is_n else _tm.get("day_duration_seconds"))
	var ratio = time_elapsed / max(dur, 1.0)
	var h = 0.0
	if not is_n: h = 6.0 + ratio * 12.0
	else: h = 18.0 + ratio * 12.0
	if h >= 24.0: h -= 24.0
	var mins = int(fmod(h * 60.0, 60.0))
	_clock_str_cache = "%02d:%02d" % [int(h), mins]

func _draw_diegetic_ui() -> void:
	if _tm == null: return
	var font = _font
	
	# 1. Analog Voltmeter (Solar Pin)
	var vx: float = -50.0
	var vy: float = -120.0
	
	# Metal casing
	var v_rect = Rect2(vx - 20, vy - 15, 40, 30)
	draw_rect(v_rect, Color(0.4, 0.4, 0.4))
	_draw_rect_outline(v_rect, OUTLINE)
	
	# Glass display
	var d_rect = Rect2(vx - 16, vy - 10, 32, 20)
	draw_rect(d_rect, Color(0.9, 0.9, 0.85))
	_draw_rect_outline(d_rect, OUTLINE)
	
	# Needle
	var solar_pct: float = _solar_pct_cache
	var angle = lerpf(PI * 0.8, PI * 0.2, solar_pct)
	var needle_end = Vector2(vx, vy + 8) + Vector2(cos(angle), -sin(angle)) * 14.0
	draw_line(Vector2(vx, vy + 8), needle_end, Color(0.8, 0.2, 0.2), 2.0)
	draw_circle(Vector2(vx, vy + 8), 2.0, OUTLINE)
	
	# Text Label "SOLAR" carved in wood
	draw_string(font, Vector2(vx - 16, vy - 18), "SOLAR", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(0.1, 0.1, 0.1, 0.5))
	
	# 2. Digital Clock on Radio
	var time_str = _clock_str_cache
	
	# Draw clock on radio at x = 82, y = -43 (Workbench)
	var rx = 85.0
	var ry = -43.0
	draw_rect(Rect2(rx, ry + 2, 20, 8), Color(0.05, 0.05, 0.05))
	draw_string(font, Vector2(rx + 2, ry + 9), time_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.9, 0.2, 0.2))
