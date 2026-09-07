extends Node2D

var _layer3: Node2D
var _camera: Node2D
var _flora_node: Node2D

var current_state: String = "dry"
var _time: float = 0.0
var _redraw_timer: float = 0.0
var _last_camera_x: float = 0.0

var _decals: Array[Dictionary] = []
var _sub_rocks: Array[Dictionary] = []
var _pebbles: Array[Dictionary] = []

# Base palettes
const PAL_DRY = {
	"interior": Color(0.40, 0.30, 0.22, 1.0),
	"porch": Color(0.35, 0.30, 0.28, 1.0),
	"peri": Color(0.32, 0.26, 0.19, 1.0),
	"desert": Color(0.40, 0.32, 0.22, 1.0),
	"cut1": Color(0.22, 0.16, 0.12, 1.0),
	"cut2": Color(0.30, 0.22, 0.14, 1.0),
	"cut3": Color(0.16, 0.12, 0.08, 1.0)
}
const PAL_WET = {
	"interior": Color(0.40, 0.30, 0.22, 1.0), # Inside stays dry usually
	"porch": Color(0.25, 0.20, 0.18, 1.0),
	"peri": Color(0.22, 0.18, 0.14, 1.0),
	"desert": Color(0.25, 0.20, 0.15, 1.0),
	"cut1": Color(0.18, 0.12, 0.08, 1.0),
	"cut2": Color(0.22, 0.16, 0.10, 1.0),
	"cut3": Color(0.12, 0.08, 0.05, 1.0)
}
const PAL_SANDY = {
	"interior": Color(0.40, 0.32, 0.24, 1.0),
	"porch": Color(0.45, 0.38, 0.30, 1.0),
	"peri": Color(0.45, 0.35, 0.25, 1.0),
	"desert": Color(0.48, 0.40, 0.30, 1.0),
	"cut1": Color(0.30, 0.24, 0.18, 1.0),
	"cut2": Color(0.35, 0.28, 0.20, 1.0),
	"cut3": Color(0.16, 0.12, 0.08, 1.0)
}
const PAL_SNOWY = {
	"interior": Color(0.40, 0.30, 0.22, 1.0),
	"porch": Color(0.85, 0.88, 0.90, 1.0),
	"peri": Color(0.90, 0.92, 0.95, 1.0),
	"desert": Color(0.88, 0.90, 0.92, 1.0),
	"cut1": Color(0.40, 0.45, 0.50, 1.0),
	"cut2": Color(0.30, 0.22, 0.14, 1.0),
	"cut3": Color(0.16, 0.12, 0.08, 1.0)
}
const PAL_SCORCHED = {
	"interior": Color(0.25, 0.18, 0.15, 1.0),
	"porch": Color(0.20, 0.15, 0.12, 1.0),
	"peri": Color(0.15, 0.10, 0.08, 1.0),
	"desert": Color(0.25, 0.20, 0.18, 1.0),
	"cut1": Color(0.15, 0.10, 0.08, 1.0),
	"cut2": Color(0.25, 0.18, 0.12, 1.0),
	"cut3": Color(0.12, 0.08, 0.05, 1.0)
}

func _ready() -> void:
	z_index = -7
	add_to_group("ground_props")
	
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 99
	
	var flora_items: Array[Dictionary] = []
	# Pebbles and flora
	for i in 60:
		var side: float = -1.0 if (i % 2 == 0) else 1.0
		var x: float = side * rng.randf_range(290.0, 1800.0)
		var y: float = rng.randf_range(-4.0, 14.0)
		var t: int = rng.randi() % 3
		var dict: Dictionary = {"x": x, "y": y, "type": t, "size": rng.randf_range(3.0, 5.5), "phase": rng.randf_range(0.0, TAU)}
		if t == 0: _pebbles.append(dict)
		else: flora_items.append(dict)

	# Sub strata rocks
	for i in 30:
		_sub_rocks.append({
			"x": rng.randf_range(-2800.0, 2800.0),
			"y": rng.randf_range(40.0, 280.0),
			"w": rng.randf_range(16.0, 42.0),
			"h": rng.randf_range(8.0, 18.0),
			"rot": rng.randf_range(-0.35, 0.35)
		})

	_flora_node = FloraAmbient.new()
	_flora_node.set("flora_items", flora_items)
	add_child(_flora_node)

	_layer3 = Node2D.new()
	_layer3.draw.connect(_draw_layer3)
	add_child(_layer3)
	move_child(_layer3, 0)
	
	_camera = get_tree().get_first_node_in_group("main_camera")
	queue_redraw()

func set_state(new_state: String) -> void:
	if current_state != new_state:
		current_state = new_state
		if _flora_node:
			_flora_node.set("current_state", current_state)
		queue_redraw()

func add_decal(type: String, global_pos: Vector2, extra: Dictionary = {}) -> void:
	# Convert global to local approx (we are at 0,0 anyway)
	var ttl = 20.0
	if current_state == "wet" or current_state == "snowy":
		ttl = 40.0
	
	_decals.append({
		"type": type,
		"x": global_pos.x,
		"y": global_pos.y,
		"ttl": ttl,
		"max_ttl": ttl,
		"extra": extra
	})
	
	if _decals.size() > 80:
		_decals.remove_at(0)

func _process(delta: float) -> void:
	_time += delta
	if _camera == null:
		_camera = get_tree().get_first_node_in_group("main_camera")
	if _camera != null:
		_layer3.position.x = _camera.global_position.x * 0.6
		
	# Update decals
	var needs_redraw = false
	for i in range(_decals.size() - 1, -1, -1):
		_decals[i].ttl -= delta
		if _decals[i].ttl <= 0:
			_decals.remove_at(i)
			needs_redraw = true

	_redraw_timer += delta
	# Redraw when camera moves significantly OR timer expires (whichever first)
	var camera_moved = false
	if _camera != null:
		var cam_pos_diff = abs(_camera.global_position.x - _last_camera_x)
		if cam_pos_diff > 8.0:
			camera_moved = true
			_last_camera_x = _camera.global_position.x
	
	if _redraw_timer >= 0.05 or camera_moved: # 20 FPS throttle or position change
		_redraw_timer = 0.0
		if _decals.size() > 0 or needs_redraw or camera_moved:
			queue_redraw()

func _get_pal() -> Dictionary:
	if current_state == "wet": return PAL_WET
	if current_state == "sandy": return PAL_SANDY
	if current_state == "snowy": return PAL_SNOWY
	if current_state == "scorched": return PAL_SCORCHED
	return PAL_DRY

func _draw() -> void:
	var pal = _get_pal()
	
	# Zone 4: Near Desert
	draw_rect(Rect2(-3200.0, -6.0, 6400.0, 24.0), pal["desert"])
	# Zone 3: Perimeter
	draw_rect(Rect2(-500.0, -6.0, 1000.0, 24.0), pal["peri"])
	# Zone 2: Porch & Steps
	draw_rect(Rect2(-280.0, -6.0, 560.0, 24.0), pal["porch"])
	# Zone 1: Interior Floor
	draw_rect(Rect2(-230.0, -6.0, 460.0, 24.0), pal["interior"])
	
	_draw_zone_details(pal)
	_draw_decals()
	_draw_cutaway_cliff_face(pal)

func _draw_zone_details(pal: Dictionary) -> void:
	# Interior planks
	var plank_col = pal["interior"].darkened(0.2)
	for i in range(-230, 230, 20):
		draw_line(Vector2(i, -6.0), Vector2(i, 18.0), plank_col, 1.5)
	
	# Porch planks
	var porch_col = pal["porch"].darkened(0.2)
	for i in [-270, -250, 250, 270]:
		draw_line(Vector2(i, -6.0), Vector2(i, 18.0), porch_col, 2.0)
	
	# Puddles if wet
	if current_state == "wet":
		draw_circle(Vector2(-350, 5), 15.0, Color(0.4, 0.5, 0.6, 0.6))
		draw_circle(Vector2(400, 8), 22.0, Color(0.4, 0.5, 0.6, 0.6))
	
	# Snow drifts if snowy
	if current_state == "snowy":
		draw_circle(Vector2(-280, -2), 12.0, Color(1,1,1,0.8))
		draw_circle(Vector2(280, 10), 18.0, Color(1,1,1,0.8))
		
	# Static Pebbles
	if current_state != "snowy" and current_state != "sandy":
		for item in _pebbles:
			draw_circle(Vector2(item.x, item.y), item.size * 0.6, Color(0.4, 0.3, 0.2))

func _draw_decals() -> void:
	for d in _decals:
		var alpha = d.ttl / d.max_ttl
		var pos = Vector2(d.x, d.y)
		if d.type == "footprint":
			var col = Color(0.1, 0.08, 0.05, alpha * 0.6)
			if current_state == "snowy": col = Color(0.5, 0.6, 0.7, alpha * 0.8)
			var w = 3.0
			if d.extra.get("is_brute", false): w = 6.0
			draw_circle(pos, w, col)
		elif d.type == "bullet":
			draw_circle(pos, 1.5, Color(0.1, 0.1, 0.1, alpha))
			draw_line(pos, pos + Vector2(2, -2), Color(0.8, 0.6, 0.2, alpha), 1.0)
		elif d.type == "scratch":
			var col = Color(0.2, 0.1, 0.1, alpha)
			draw_line(pos + Vector2(-4,-4), pos + Vector2(4,4), col, 1.5)
			draw_line(pos + Vector2(-2,-6), pos + Vector2(6,2), col, 1.5)
			draw_line(pos + Vector2(-6,-2), pos + Vector2(2,6), col, 1.5)

func _draw_cutaway_cliff_face(pal: Dictionary) -> void:
	# Zone 6
	draw_rect(Rect2(-3200.0, 18.0, 6400.0, 4.0), pal["cut1"].darkened(0.2)) # Cliff edge
	draw_rect(Rect2(-3200.0, 22.0, 6400.0, 40.0), pal["cut1"]) # Top soil
	draw_rect(Rect2(-3200.0, 62.0, 6400.0, 80.0), pal["cut2"]) # Sand layer
	draw_rect(Rect2(-3200.0, 142.0, 6400.0, 160.0), pal["cut3"]) # Bedrock

	for rock in _sub_rocks:
		var rx = rock.x; var ry = rock.y; var rw = rock.w; var rh = rock.h; var r_rot = rock.rot
		var half_w = rw * 0.5; var half_h = rh * 0.5
		var pts = PackedVector2Array([
			Vector2(rx - half_w, ry - half_h + r_rot * 10.0),
			Vector2(rx + half_w * 0.8, ry - half_h - r_rot * 8.0),
			Vector2(rx + half_w, ry + half_h + r_rot * 5.0),
			Vector2(rx - half_w * 0.7, ry + half_h - r_rot * 6.0)
		])
		draw_colored_polygon(pts, Color(0.25, 0.2, 0.16))
		pts.append(pts[0])
		draw_polyline(pts, Color(0.1, 0.1, 0.1, 0.8), 1.2)

	var root_col = Color(0.3, 0.2, 0.1, 0.8)
	for root_x in [-1800.0, -1100.0, -600.0, -320.0, 420.0, 750.0, 1350.0, 2100.0]:
		draw_line(Vector2(root_x, 18.0), Vector2(root_x + 8.0, 45.0), root_col, 2.5)
		draw_line(Vector2(root_x + 8.0, 45.0), Vector2(root_x + 18.0, 85.0), root_col, 1.8)
		draw_line(Vector2(root_x + 8.0, 45.0), Vector2(root_x - 12.0, 75.0), root_col, 1.4)

func _draw_layer3() -> void:
	var c_col = Color(0.25, 0.18, 0.12, 1.0)
	if current_state == "wet": c_col = Color(0.2, 0.15, 0.1, 1.0)
	elif current_state == "sandy": c_col = Color(0.35, 0.28, 0.2, 1.0)
	elif current_state == "snowy": c_col = Color(0.7, 0.75, 0.8, 1.0)
	
	_layer3.draw_rect(Rect2(-4000.0, -120.0, 8000.0, 114.0), c_col)
	var rng = RandomNumberGenerator.new(); rng.seed = 44
	var dx = -4000.0
	while dx < 4000.0:
		var w = rng.randf_range(200.0, 600.0)
		var h = rng.randf_range(30.0, 80.0)
		var pts = PackedVector2Array([
			Vector2(dx, -6.0), Vector2(dx + w*0.5, -6.0 - h), Vector2(dx + w, -6.0)
		])
		_layer3.draw_colored_polygon(pts, c_col.lightened(0.1))
		_layer3.draw_polyline(pts, c_col.darkened(0.2), 2.0)
		if rng.randf() < 0.3 and current_state != "snowy":
			_layer3.draw_line(Vector2(dx + w*0.3, -6.0), Vector2(dx + w*0.3, -40.0), Color(0.1, 0.1, 0.1, 1.0), 3.0)
		dx += w * 0.8

class FloraAmbient extends Node2D:
	var flora_items: Array[Dictionary] = []
	var current_state: String = "dry"
	var _time: float = 0.0
	var _redraw_timer: float = 0.0

	func _process(delta: float) -> void:
		_time += delta * 2.2
		_redraw_timer += delta
		if _redraw_timer >= 0.066:
			_redraw_timer = 0.0
			queue_redraw()

	func _draw() -> void:
		if current_state == "snowy" or current_state == "sandy" or current_state == "scorched":
			return # Hide flora in extreme weather
			
		var grass_col = Color(0.38, 0.48, 0.26, 0.85)
		if current_state == "wet": grass_col = Color(0.28, 0.38, 0.16, 0.95)
			
		for item in flora_items:
			var x: float = item.x
			var y: float = item.y
			var sz: float = item.size
			var ph: float = item.phase
			var t: int = item.type
			
			draw_circle(Vector2(x + 1.0, y + 2.0), sz * 0.7, Color(0,0,0,0.3))

			if t == 1:
				var sway: float = sin(_time + ph) * 2.0
				draw_line(Vector2(x - 2.0, y), Vector2(x - 4.0 + sway, y - sz * 1.5), grass_col, 1.3)
				draw_line(Vector2(x, y), Vector2(x + sway, y - sz * 1.8), grass_col.lightened(0.2), 1.5)
				draw_line(Vector2(x + 2.0, y), Vector2(x + 4.0 + sway, y - sz * 1.3), grass_col, 1.3)
			else:
				var sway: float = sin(_time + ph) * 1.5
				draw_line(Vector2(x, y), Vector2(x + sway, y - sz * 1.5), grass_col, 1.2)
				var flower_col: Color = Color(0.95, 0.82, 0.32, 1.0) if (int(ph * 10.0) % 2 == 0) else Color(0.92, 0.92, 0.88, 1.0)
				draw_circle(Vector2(x + sway, y - sz * 1.5), 2.2, flower_col)
