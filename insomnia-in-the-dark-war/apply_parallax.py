import re, os

path = 'scripts/art_skyline.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace _draw with sub-draws and process
new_structure = '''
var layer5: Node2D
var layer4: Node2D
var _camera: Node2D

func _ready() -> void:
	z_index = -10
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 88
	
	# Far buildings across entire wide world [-4000, 4000]
	var x: float = -4000.0
	while x < 4000.0:
		var w: float = rng.randf_range(80.0, 160.0)
		var h: float = rng.randf_range(70.0, 180.0)
		if not (x + w > -420.0 and x < 420.0):
			_far_buildings.append(Rect2(x, -h, w, h))
		x += rng.randf_range(90.0, 180.0)
		
	# Mid buildings
	x = -4000.0
	while x < 4000.0:
		var w: float = rng.randf_range(60.0, 120.0)
		var h: float = rng.randf_range(40.0, 130.0)
		if not (x + w > -420.0 and x < 420.0):
			_mid_buildings.append(Rect2(x, -h, w, h))
		x += rng.randf_range(110.0, 200.0)

	layer5 = Node2D.new()
	layer5.draw.connect(_draw_layer5)
	add_child(layer5)
	
	layer4 = Node2D.new()
	layer4.draw.connect(_draw_layer4)
	add_child(layer4)

	# Add separate child node for dynamic ambient birds & leaves
	var ambient_particles := SkylineAmbient.new()
	layer4.add_child(ambient_particles)
	
	_camera = get_tree().get_first_node_in_group("main_camera")

func _process(_delta: float) -> void:
	if _camera == null:
		_camera = get_tree().get_first_node_in_group("main_camera")
	
	if _camera != null:
		layer5.position.x = _camera.global_position.x * 0.98
		layer4.position.x = _camera.global_position.x * 0.85

func _draw_layer5() -> void:
	_draw_gradient_sky(layer5)
	_draw_sun(layer5)

func _draw_layer4() -> void:
	_draw_buildings(layer4)
	_draw_power_poles(layer4)
	_draw_power_lines(layer4)

func _draw_gradient_sky(canvas: Node2D) -> void:
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
		canvas.draw_rect(Rect2(-2500.0, y, 5000.0, band_h), col)

func _draw_sun(canvas: Node2D) -> void:
	var sun_pos: Vector2 = Vector2(-750.0, -320.0)
	canvas.draw_circle(sun_pos, 70.0, Color(SUN_HALO.r, SUN_HALO.g, SUN_HALO.b, 0.06))
	canvas.draw_circle(sun_pos, 45.0, Color(SUN_HALO.r, SUN_HALO.g, SUN_HALO.b, 0.12))
	canvas.draw_circle(sun_pos, 28.0, Color(SUN_HALO.r, SUN_HALO.g, SUN_HALO.b, 0.22))
	canvas.draw_circle(sun_pos, 20.0, SUN_CORE)

func _draw_buildings(canvas: Node2D) -> void:
	for rect in _far_buildings:
		canvas.draw_rect(rect, FAR_BUILDING)
		canvas.draw_line(Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y), Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y - 18.0), FAR_BUILDING, 1.2)
		
	for rect in _mid_buildings:
		canvas.draw_rect(rect, MID_BUILDING)
		var win_y: float = rect.position.y + 12.0
		while win_y < rect.position.y + rect.size.y - 12.0:
			canvas.draw_rect(Rect2(rect.position.x + 8.0, win_y, 4.0, 6.0), Color(1.0, 0.85, 0.5, 0.25))
			if rect.size.x > 70.0:
				canvas.draw_rect(Rect2(rect.position.x + rect.size.x - 14.0, win_y, 4.0, 6.0), Color(1.0, 0.85, 0.5, 0.18))
			win_y += 18.0

func _draw_power_poles(canvas: Node2D) -> void:
	var pole_x: float = -4000.0
	while pole_x < 4000.0:
		if abs(pole_x) > 280.0:
			canvas.draw_line(Vector2(pole_x, 0.0), Vector2(pole_x, -160.0), SILHOUETTE, 3.0)
			canvas.draw_line(Vector2(pole_x - 18.0, -145.0), Vector2(pole_x + 18.0, -145.0), SILHOUETTE, 2.2)
			canvas.draw_line(Vector2(pole_x - 14.0, -125.0), Vector2(pole_x + 14.0, -125.0), SILHOUETTE, 2.0)
			canvas.draw_circle(Vector2(pole_x - 17.0, -145.0), 1.8, Color(0.7, 0.7, 0.7))
			canvas.draw_circle(Vector2(pole_x + 17.0, -145.0), 1.8, Color(0.7, 0.7, 0.7))
			canvas.draw_circle(Vector2(pole_x - 13.0, -125.0), 1.8, Color(0.7, 0.7, 0.7))
			canvas.draw_circle(Vector2(pole_x + 13.0, -125.0), 1.8, Color(0.7, 0.7, 0.7))
		pole_x += 340.0

func _draw_power_lines(canvas: Node2D) -> void:
	var prev_pole: Vector2 = Vector2.ZERO
	var has_prev: bool = false
	var pole_x: float = -4000.0
	while pole_x < 4000.0:
		if abs(pole_x) > 280.0:
			var cur_pole: Vector2 = Vector2(pole_x, -145.0)
			if has_prev:
				_draw_sagging_wire(canvas, prev_pole, cur_pole, 16.0)
				_draw_sagging_wire(canvas, prev_pole + Vector2(0.0, 20.0), cur_pole + Vector2(0.0, 20.0), 12.0)
			prev_pole = cur_pole
			has_prev = true
		pole_x += 340.0

func _draw_sagging_wire(canvas: Node2D, from_pt: Vector2, to_pt: Vector2, sag: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	var segs: int = 12
	for i in segs + 1:
		var t: float = float(i) / float(segs)
		var p: Vector2 = from_pt.lerp(to_pt, t)
		p.y += sin(t * PI) * sag
		pts.append(p)
	canvas.draw_polyline(pts, Color(0.12, 0.10, 0.15, 0.65), 1.0)
'''

# Use regex to replace from _ready to _draw_sagging_wire
content = re.sub(r'func _ready\(\) -> void:.*func _draw_sagging_wire[^\n]+\n.*?canvas\.draw_polyline[^\n]+\n', new_structure, content, flags=re.DOTALL)
# wait, the original didn't have canvas.draw_polyline, it had draw_polyline
content = re.sub(r'func _ready\(\) -> void:.*func _draw_sagging_wire[^\n]+\n.*?draw_polyline[^\n]+\n', new_structure, content, flags=re.DOTALL)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated art_skyline.gd")
