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
var _birds: Array[Dictionary] = []
var _leaves: Array[Dictionary] = []
var _anim_time: float = 0.0


func _ready() -> void:
	z_index = -10
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 88
	
	# Far buildings
	var x: float = -1250.0
	while x < 1250.0:
		var w: float = rng.randf_range(80.0, 160.0)
		var h: float = rng.randf_range(70.0, 180.0)
		if not (x + w > -420.0 and x < 420.0):
			_far_buildings.append(Rect2(x, -h, w, h))
		x += rng.randf_range(90.0, 180.0)
		
	# Mid buildings with broken windows/towers
	x = -1250.0
	while x < 1250.0:
		var w: float = rng.randf_range(60.0, 120.0)
		var h: float = rng.randf_range(40.0, 130.0)
		if not (x + w > -420.0 and x < 420.0):
			_mid_buildings.append(Rect2(x, -h, w, h))
		x += rng.randf_range(110.0, 200.0)
		
	# Flocks of birds
	for i in 6:
		_birds.append({
			"x": rng.randf_range(-1100.0, 1100.0),
			"y": rng.randf_range(-380.0, -180.0),
			"speed": rng.randf_range(25.0, 45.0),
			"flap_offset": rng.randf_range(0.0, TAU)
		})
		
	# Ambient floating leaves
	for i in 8:
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
			
	queue_redraw()


func _draw() -> void:
	_draw_gradient_sky()
	_draw_sun()
	_draw_buildings()
	_draw_power_poles()
	_draw_power_lines()
	_draw_birds()
	_draw_leaves()


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
	# Soft outer halos
	draw_circle(sun_pos, 70.0, Color(SUN_HALO.r, SUN_HALO.g, SUN_HALO.b, 0.06))
	draw_circle(sun_pos, 45.0, Color(SUN_HALO.r, SUN_HALO.g, SUN_HALO.b, 0.12))
	draw_circle(sun_pos, 28.0, Color(SUN_HALO.r, SUN_HALO.g, SUN_HALO.b, 0.22))
	# Sun disk
	draw_circle(sun_pos, 20.0, SUN_CORE)


func _draw_buildings() -> void:
	# Far layer
	for rect in _far_buildings:
		draw_rect(rect, FAR_BUILDING)
		# Antenna spire on top
		draw_line(Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y), Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y - 18.0), FAR_BUILDING, 1.5)
		
	# Mid layer
	for rect in _mid_buildings:
		draw_rect(rect, MID_BUILDING)
		# Rooftop water tower or broken rubble
		var cx: float = rect.position.x + rect.size.x * 0.5
		draw_rect(Rect2(cx - 8.0, rect.position.y - 12.0, 16.0, 12.0), MID_BUILDING)
		# Broken windows grid
		var wy: float = rect.position.y + 10.0
		while wy < -10.0:
			var wx: float = rect.position.x + 8.0
			while wx < rect.position.x + rect.size.x - 8.0:
				draw_rect(Rect2(wx, wy, 4.0, 6.0), Color(0.15, 0.12, 0.20, 0.5))
				wx += 12.0
			wy += 14.0


func _draw_power_poles() -> void:
	for px in [-920.0, 880.0]:
		draw_line(Vector2(px, 0.0), Vector2(px, -260.0), SILHOUETTE, 4.0)
		draw_line(Vector2(px - 36.0, -250.0), Vector2(px + 36.0, -250.0), SILHOUETTE, 6.0)
		draw_line(Vector2(px - 26.0, -215.0), Vector2(px + 26.0, -215.0), SILHOUETTE, 4.0)
		draw_line(Vector2(px - 16.0, -180.0), Vector2(px + 16.0, -180.0), SILHOUETTE, 3.0)
		# Small transformer cylinder
		draw_rect(Rect2(px + 3.0, -235.0, 8.0, 14.0), SILHOUETTE)


func _draw_power_lines() -> void:
	# Gently sagging power lines
	var t_pts_1: PackedVector2Array = PackedVector2Array()
	var t_pts_2: PackedVector2Array = PackedVector2Array()
	var segs: int = 16
	for i in segs + 1:
		var t: float = float(i) / float(segs)
		var x: float = lerpf(-920.0, 880.0, t)
		var sag: float = sin(t * PI) * 16.0
		t_pts_1.append(Vector2(x, -245.0 + sag))
		t_pts_2.append(Vector2(x, -210.0 + sag))
	draw_polyline(t_pts_1, Color(SILHOUETTE.r, SILHOUETTE.g, SILHOUETTE.b, 0.8), 1.2)
	draw_polyline(t_pts_2, Color(SILHOUETTE.r, SILHOUETTE.g, SILHOUETTE.b, 0.8), 1.2)


func _draw_birds() -> void:
	for b in _birds:
		var bx: float = float(b["x"])
		var by: float = float(b["y"])
		var flap: float = sin(_anim_time * 8.0 + float(b["flap_offset"])) * 3.0
		draw_line(Vector2(bx - 7.0, by + flap), Vector2(bx, by), SILHOUETTE, 1.5)
		draw_line(Vector2(bx, by), Vector2(bx + 7.0, by + flap), SILHOUETTE, 1.5)


func _draw_leaves() -> void:
	for l in _leaves:
		var lx: float = float(l["x"])
		var ly: float = float(l["y"])
		draw_circle(Vector2(lx, ly), 2.2, Color(0.85, 0.55, 0.32, 0.65))
