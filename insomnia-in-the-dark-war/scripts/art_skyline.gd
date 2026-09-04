extends Node2D

const SKY_TOP: Color = Color(0.14, 0.13, 0.26, 1.0)
const SKY_MID: Color = Color(0.44, 0.26, 0.38, 1.0)
const SKY_HORIZON: Color = Color(0.76, 0.48, 0.38, 1.0)
const SUN_CORE: Color = Color(1.0, 0.90, 0.72, 0.95)
const SUN_HALO: Color = Color(1.0, 0.65, 0.35, 0.12)
const FAR_BUILDING: Color = Color(0.38, 0.28, 0.36, 0.65)
const MID_BUILDING: Color = Color(0.25, 0.18, 0.28, 0.85)
const NEAR_BUILDING: Color = Color(0.16, 0.14, 0.22, 1.0)
const SILHOUETTE: Color = Color(0.12, 0.11, 0.18, 1.0)

var _far_buildings: Array[Rect2] = []
var _mid_buildings: Array[Rect2] = []


func _ready() -> void:
	z_index = -10
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 88
	
	# Far buildings across entire wide world [-3200, 3200]
	var x: float = -3200.0
	while x < 3200.0:
		var w: float = rng.randf_range(80.0, 160.0)
		var h: float = rng.randf_range(70.0, 180.0)
		if not (x + w > -420.0 and x < 420.0):
			_far_buildings.append(Rect2(x, -h, w, h))
		x += rng.randf_range(90.0, 180.0)
		
	# Mid buildings with broken windows/towers
	x = -3200.0
	while x < 3200.0:
		var w: float = rng.randf_range(60.0, 120.0)
		var h: float = rng.randf_range(40.0, 130.0)
		if not (x + w > -420.0 and x < 420.0):
			_mid_buildings.append(Rect2(x, -h, w, h))
		x += rng.randf_range(110.0, 200.0)

	# Add separate child node for dynamic ambient birds & leaves
	var ambient_particles := SkylineAmbient.new()
	add_child(ambient_particles)


func _draw() -> void:
	# Static elements rendered once: 0% CPU usage per frame!
	_draw_gradient_sky()
	_draw_sun()
	_draw_buildings()
	_draw_power_poles()
	_draw_power_lines()


func _draw_gradient_sky() -> void:
	# 3-stop smooth gradient sky
	var band_h: float = 24.0
	var bands: int = 30
	for i in bands:
		var t: float = float(i) / float(bands)
		var col: Color
		if t < 0.5:
			col = SKY_TOP.lerp(SKY_MID, t * 2.0)
		else:
			col = SKY_MID.lerp(SKY_HORIZON, (t - 0.5) * 2.0)
		var y: float = -720.0 + band_h * float(i)
		draw_rect(Rect2(-1250.0, y, 2500.0, band_h), col)


func _draw_sun() -> void:
	var sun_pos: Vector2 = Vector2(-750.0, -320.0)
	draw_circle(sun_pos, 70.0, Color(SUN_HALO.r, SUN_HALO.g, SUN_HALO.b, 0.06))
	draw_circle(sun_pos, 45.0, Color(SUN_HALO.r, SUN_HALO.g, SUN_HALO.b, 0.12))
	draw_circle(sun_pos, 28.0, Color(SUN_HALO.r, SUN_HALO.g, SUN_HALO.b, 0.22))
	draw_circle(sun_pos, 20.0, SUN_CORE)


func _draw_buildings() -> void:
	for rect in _far_buildings:
		draw_rect(rect, FAR_BUILDING)
		draw_line(Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y), Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y - 18.0), FAR_BUILDING, 1.2)
		
	for rect in _mid_buildings:
		draw_rect(rect, MID_BUILDING)
		var win_y: float = rect.position.y + 12.0
		while win_y < rect.position.y + rect.size.y - 12.0:
			draw_rect(Rect2(rect.position.x + 8.0, win_y, 4.0, 6.0), Color(1.0, 0.85, 0.5, 0.25))
			if rect.size.x > 70.0:
				draw_rect(Rect2(rect.position.x + rect.size.x - 14.0, win_y, 4.0, 6.0), Color(1.0, 0.85, 0.5, 0.18))
			win_y += 18.0


func _draw_power_poles() -> void:
	var pole_x: float = -1200.0
	while pole_x < 1200.0:
		if abs(pole_x) > 280.0:
			draw_line(Vector2(pole_x, 0.0), Vector2(pole_x, -160.0), SILHOUETTE, 3.0)
			draw_line(Vector2(pole_x - 18.0, -145.0), Vector2(pole_x + 18.0, -145.0), SILHOUETTE, 2.2)
			draw_line(Vector2(pole_x - 14.0, -125.0), Vector2(pole_x + 14.0, -125.0), SILHOUETTE, 2.0)
			draw_circle(Vector2(pole_x - 17.0, -145.0), 1.8, Color(0.7, 0.7, 0.7))
			draw_circle(Vector2(pole_x + 17.0, -145.0), 1.8, Color(0.7, 0.7, 0.7))
			draw_circle(Vector2(pole_x - 13.0, -125.0), 1.8, Color(0.7, 0.7, 0.7))
			draw_circle(Vector2(pole_x + 13.0, -125.0), 1.8, Color(0.7, 0.7, 0.7))
		pole_x += 340.0


func _draw_power_lines() -> void:
	var prev_pole: Vector2 = Vector2.ZERO
	var has_prev: bool = false
	var pole_x: float = -1200.0
	while pole_x < 1200.0:
		if abs(pole_x) > 280.0:
			var cur_pole: Vector2 = Vector2(pole_x, -145.0)
			if has_prev:
				_draw_sagging_wire(prev_pole, cur_pole, 16.0)
				_draw_sagging_wire(prev_pole + Vector2(0.0, 20.0), cur_pole + Vector2(0.0, 20.0), 12.0)
			prev_pole = cur_pole
			has_prev = true
		pole_x += 340.0


func _draw_sagging_wire(from_pt: Vector2, to_pt: Vector2, sag: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	var segs: int = 12
	for i in segs + 1:
		var t: float = float(i) / float(segs)
		var p: Vector2 = from_pt.lerp(to_pt, t)
		p.y += sin(t * PI) * sag
		pts.append(p)
	draw_polyline(pts, Color(0.12, 0.10, 0.15, 0.65), 1.0)


# --- Lightweight Child Node for Animating Birds & Leaves only ---
class SkylineAmbient extends Node2D:
	var _birds: Array[Dictionary] = []
	var _leaves: Array[Dictionary] = []
	var _anim_time: float = 0.0
	var _redraw_cooldown: float = 0.0

	func _ready() -> void:
		var rng := RandomNumberGenerator.new()
		rng.seed = 88
		for i in 5:
			_birds.append({
				"x": rng.randf_range(-1100.0, 1100.0),
				"y": rng.randf_range(-380.0, -180.0),
				"speed": rng.randf_range(25.0, 45.0),
				"flap_offset": rng.randf_range(0.0, TAU)
			})
		for i in 6:
			_leaves.append({
				"x": rng.randf_range(-1100.0, 1100.0),
				"y": rng.randf_range(-140.0, 60.0),
				"fall": rng.randf_range(15.0, 30.0),
				"drift": rng.randf_range(-12.0, 12.0),
				"phase": rng.randf_range(0.0, TAU)
			})

	func _process(delta: float) -> void:
		_anim_time += delta
		for b in _birds:
			b["x"] = float(b["x"]) + float(b["speed"]) * delta
			if float(b["x"]) > 1150.0:
				b["x"] = -1150.0
				b["y"] = randf_range(-380.0, -180.0)

		for l in _leaves:
			l["y"] = float(l["y"]) + float(l["fall"]) * delta
			l["x"] = float(l["x"]) + float(l["drift"]) * delta + sin(float(l["phase"]) + _anim_time * 2.0) * 0.8
			if float(l["y"]) > 60.0:
				l["y"] = -140.0
				l["x"] = randf_range(-1100.0, 1100.0)

		# Throttle redraw to 30 fps instead of uncapped 60+ fps for leaves/birds
		_redraw_cooldown += delta
		if _redraw_cooldown >= 0.033:
			_redraw_cooldown = 0.0
			queue_redraw()

	func _draw() -> void:
		# Draw only the 5 birds and 6 leaves
		for b in _birds:
			var bx: float = float(b["x"])
			var by: float = float(b["y"])
			var flap: float = sin(_anim_time * 4.5 + float(b["flap_offset"])) * 3.5
			draw_line(Vector2(bx - 5.0, by - flap), Vector2(bx, by), Color(0.15, 0.13, 0.20, 0.8), 1.2)
			draw_line(Vector2(bx, by), Vector2(bx + 5.0, by - flap), Color(0.15, 0.13, 0.20, 0.8), 1.2)

		for l in _leaves:
			var lx: float = float(l["x"])
			var ly: float = float(l["y"])
			draw_line(Vector2(lx - 2.0, ly), Vector2(lx + 2.0, ly + 1.0), Color(0.85, 0.50, 0.30, 0.7), 1.2)
